import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// BẮT BUỘC: Background handler phải là top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // đã init rồi thì bỏ qua
  }
  // TODO: xử lý data-only nếu cần
}

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNoti =
      FlutterLocalNotificationsPlugin();

  // --- NEW: Controllers to expose FCM events ---
  static final StreamController<Map<String, dynamic>> _onMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>>
      _onMessageOpenedAppController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Public streams for consumers (e.g., NotificationCubit)
  static Stream<Map<String, dynamic>> get onMessage =>
      _onMessageController.stream;
  static Stream<Map<String, dynamic>> get onMessageOpenedApp =>
      _onMessageOpenedAppController.stream;

  // --- NEW: optional callback to upload token to backend ---
  // set via FcmService.setTokenUploadHandler(...)
  static Future<void> Function(String token)? _tokenUploadHandler;
  static void setTokenUploadHandler(Future<void> Function(String token)? cb) {
    _tokenUploadHandler = cb;
  }

  /// Gọi duy nhất 1 lần khi app start (sau Firebase.initializeApp)
  static Future<void> init() async {
    // Đảm bảo Firebase đã init (an toàn nếu gọi lặp)
    try {
      await Firebase.initializeApp();
    } catch (_) {}

    // Quyền thông báo (Android 13+ / iOS)
    await _messaging.requestPermission();

    // === Channel Android mặc định: bật âm thanh + rung (không pattern) ===
    final AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications.',
      importance: Importance.high, // âm thanh mặc định + ưu tiên cao
      playSound: true, // âm thanh mặc định
      enableVibration: true, // rung mặc định
    );

    // Khởi tạo plugin local notifications
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNoti.initialize(initSettings);

    // Tạo channel (Android)
    await _localNoti
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Lấy token (nếu cần gửi về server)
    final token = await _messaging.getToken();
    if (token != null) {
      // call upload handler if provided
      try {
        await _tokenUploadHandler?.call(token);
      } catch (_) {}
    }

    // Lắng nghe refresh token
    _messaging.onTokenRefresh.listen((t) async {
      try {
        await _tokenUploadHandler?.call(t);
      } catch (_) {}
    });

    // === Foreground: hiển thị noti + xử lý data ===
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showForegroundNotification(message);
      final payload = _normalizeMessage(message);
      _onMessageController.add(payload);
      _handleData(message.data);
    });

    // === User bấm noti khi app background → foreground ===
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final payload = _normalizeMessage(message);
      _onMessageOpenedAppController.add(payload);
      _handleData(message.data);
    });

    // === App mở từ trạng thái tắt nhờ bấm noti ===
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      final payload = _normalizeMessage(initial);
      // Add to opened stream so listeners can handle initial deep-link
      _onMessageOpenedAppController.add(payload);
      _handleData(initial.data);
    }
  }

  /// Hiển thị noti khi app đang foreground (âm thanh & rung mặc định)
  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    await _localNoti.show(
      notif.hashCode,
      notif.title ?? 'Thông báo',
      notif.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true, // âm thanh mặc định
          enableVibration: true, // rung mặc định
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true, // âm thanh mặc định iOS
        ),
      ),
    );
  }

  /// Normalize RemoteMessage -> Map for consumers
  static Map<String, dynamic> _normalizeMessage(RemoteMessage message) {
    final notif = message.notification;
    return {
      'notification': {
        'title': notif?.title,
        'body': notif?.body,
      },
      'data': message.data ?? {},
      'messageId': message.messageId,
    };
  }

  /// Tuỳ biến hành vi theo data từ BE
  static void _handleData(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    final action = data['action'];
    switch (action) {
      case 'reload_project':
        final projectId = data['projectId'];
        // TODO: gọi provider/bloc để reload project theo projectId
        break;
      default:
        break;
    }
  }

  /// Optional: dispose controllers if needed (not usually required for app lifecycle)
  static Future<void> dispose() async {
    await _onMessageController.close();
    await _onMessageOpenedAppController.close();
  }
}
