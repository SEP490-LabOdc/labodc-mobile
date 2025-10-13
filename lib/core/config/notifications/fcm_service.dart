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
      playSound: true,             // âm thanh mặc định
      enableVibration: true,       // rung mặc định
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
    // TODO: POST token lên server của bạn
    // print('FCM token: $token');

    // Lắng nghe refresh token
    _messaging.onTokenRefresh.listen((t) {
      // TODO: cập nhật token mới lên server
    });

    // === Foreground: hiển thị noti + xử lý data ===
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showForegroundNotification(message);
      _handleData(message.data);
    });

    // === User bấm noti khi app background → foreground ===
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleData(message.data);
    });

    // === App mở từ trạng thái tắt nhờ bấm noti ===
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
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
          playSound: true,     // âm thanh mặc định
          enableVibration: true, // rung mặc định
          // icon không set → dùng app icon mặc định
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true, // âm thanh mặc định iOS
        ),
      ),
    );
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
}
