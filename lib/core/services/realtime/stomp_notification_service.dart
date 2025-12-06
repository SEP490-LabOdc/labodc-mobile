import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../../features/notification/data/models/notification_model.dart';
import '../../../../features/notification/domain/entities/notification_entity.dart';

class StompNotificationService {
  StompClient? _client;
  bool _connected = false;
  String? _userId;
  String? _token;

  int _urlIndex = 0;

  final List<String> _endpoints = [
    'wss://api.labodc.id.vn/ws/websocket', // [Ưu tiên 1]
    'wss://api.labodc.id.vn/ws-native',    // [Ưu tiên 2]
  ];

  final StreamController<NotificationEntity> _controller = StreamController.broadcast();

  Stream<NotificationEntity> get notificationsStream => _controller.stream;
  bool get isConnected => _connected;

  Future<void> connect({
    required String userId,
    required String accessToken,
  }) async {
    if (_connected && _userId == userId && _token == accessToken) {
      return;
    }

    _userId = userId;
    _token = accessToken;
    _urlIndex = 0;

    _disconnectInternal();
    _tryConnect();
  }

  void _tryConnect() {
    if (_urlIndex >= _endpoints.length) {
      debugPrint("❌ [Stomp] All endpoints failed. Will retry in 5 seconds...");
      _urlIndex = 0;
      Future.delayed(const Duration(seconds: 5), _tryConnect);
      return;
    }

    final currentUrl = _endpoints[_urlIndex];
    debugPrint("🔄 [Stomp] Connecting to: $currentUrl");

    _client = StompClient(
      config: StompConfig(
        url: currentUrl,
        stompConnectHeaders: {'Authorization': 'Bearer $_token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $_token'},
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) {
          debugPrint("⚠️ [Stomp] Error on $currentUrl: $error");
          _handleConnectionFailure();
        },
        onDisconnect: (_) {
          _connected = false;
          debugPrint("🔌 [Stomp] Disconnected");
        },
        reconnectDelay: const Duration(seconds: 5),
        heartbeatIncoming: const Duration(seconds: 30),
        heartbeatOutgoing: const Duration(seconds: 30),
      ),
    );

    _client!.activate();
  }

  void _handleConnectionFailure() {
    _connected = false;
    _client?.deactivate();
    _urlIndex++;
    Future.delayed(const Duration(milliseconds: 500), _tryConnect);
  }

  void _onConnect(StompFrame frame) {
    _connected = true;
    debugPrint("✅ [Stomp] Connected!");

    const destStandard = '/user/queue/notifications';
    _subscribeTo(destStandard, "Standard");

    if (_userId != null) {
      final destSpecific = '/user/$_userId/queue/notifications';
      _subscribeTo(destSpecific, "Specific");
    }
  }

  void _subscribeTo(String destination, String label) {
    _client?.subscribe(
      destination: destination,
      callback: (frame) {
        if (frame.body == null) return;
        try {
          debugPrint("📩 [Stomp][$label] Raw: ${frame.body}");

          var jsonData = jsonDecode(frame.body!);

          if (jsonData is! Map<String, dynamic>) return;

          // --- [LOGIC SỬA LỖI QUAN TRỌNG] ---

          // 1. Kiểm tra xem đây có phải là Wrapper không?
          // Wrapper là khi KHÔNG có ID ở ngoài, nhưng lại có 'data' bên trong.
          // Nếu ĐÃ CÓ 'notificationRecipientId' ở ngoài rồi thì TUYỆT ĐỐI KHÔNG BÓC TÁCH nữa.
          bool hasIdAtRoot = jsonData.containsKey('notificationRecipientId') &&
              jsonData['notificationRecipientId'] != null;

          if (!hasIdAtRoot && jsonData.containsKey('data') && jsonData['data'] is Map<String, dynamic>) {
            debugPrint("🧹 [Stomp] Detected wrapper without ID at root. Unwrapping 'data'...");
            jsonData = jsonData['data'];
            // Check lại ID sau khi bóc
            hasIdAtRoot = jsonData.containsKey('notificationRecipientId') &&
                jsonData['notificationRecipientId'] != null;
          }

          // 2. Nếu vẫn không có ID -> Bỏ qua (Tin rác hoặc tin confirm success)
          if (!hasIdAtRoot) {
            debugPrint("⚠️ [Stomp] Ignored invalid/confirmation message (No ID found).");
            return;
          }

          // -----------------------------------

          final model = NotificationModel.fromJson(jsonData);

          final notif = NotificationEntity(
            notificationRecipientId: model.notificationRecipientId,
            type: model.type,
            title: model.title,
            content: model.content,
            data: model.data,
            category: model.category,
            priority: model.priority,
            deepLink: model.deepLink,
            sentAt: model.sentAt,
            readStatus: model.readStatus,
          );

          _controller.add(notif);
          debugPrint("✨ [Stomp] Pushed '${notif.title}' to Stream");

        } catch (e) {
          debugPrint("❌ [Stomp] Processing Error: $e");
        }
      },
    );
  }

  void markAsRead(String notificationRecipientId) {
    if (!_connected || _userId == null) return;
    final dest = '/app/users/$_userId/notifications/$notificationRecipientId/read';
    _client?.send(
      destination: dest,
      headers: {'Authorization': 'Bearer $_token'},
    );
  }

  void disconnect() {
    _disconnectInternal();
    _userId = null;
    _token = null;
  }

  void _disconnectInternal() {
    _client?.deactivate();
    _connected = false;
  }
}