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

  final StreamController<NotificationEntity> _controller =
  StreamController.broadcast();

  Stream<NotificationEntity> get notificationsStream => _controller.stream;

  Future<void> connect({
    required String userId,
    required String accessToken,
  }) async {
    _userId = userId;
    _token = accessToken;

    _client = StompClient(
      config: StompConfig(
        url: 'wss://api.labodc.id.vn/ws-native',
        stompConnectHeaders: {'Authorization': 'Bearer $accessToken'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $accessToken'},
        onConnect: _onConnect,
        onWebSocketError: (err) => debugPrint("❌ WS error: $err"),
        onDisconnect: (_) => _connected = false,
        heartbeatIncoming: const Duration(seconds: 30),
        heartbeatOutgoing: const Duration(seconds: 30),
      ),
    );

    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    _connected = true;
    final dest = '/user/$_userId/queue/notifications';
    debugPrint("✅ Subscribed to $dest");

    _client?.subscribe(
      destination: dest,
      callback: (frame) {
        if (frame.body == null) return;
        try {
          final jsonData = jsonDecode(frame.body!);
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
        } catch (e) {
          debugPrint("❌ STOMP parse error: $e");
        }
      },
    );
  }

  void markAsRead(String notificationRecipientId) {
    if (!_connected) return;
    final dest =
        '/app/users/$_userId/notifications/$notificationRecipientId/read';
    _client?.send(destination: dest, headers: {'Authorization': 'Bearer $_token'});
  }

  Future<void> reconnectWithNewToken(String userId, String newToken) async {
    disconnect();
    await connect(userId: userId, accessToken: newToken);
  }

  void disconnect() {
    _client?.deactivate();
    _connected = false;
  }

  void dispose() {
    _controller.close();
    disconnect();
  }
}
