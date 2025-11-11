import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../../features/notification/data/models/notification_model.dart';

class StompNotificationService {
  StompClient? _stompClient;
  final _controller = StreamController<List<NotificationModel>>.broadcast();

  Stream<List<NotificationModel>> get notificationsStream => _controller.stream;

  bool _connected = false;
  String? _userId;
  String? _token;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 3;
  Timer? _reconnectTimer;

  /// Kết nối tới STOMP Server (dùng SockJS)
  Future<void> connect({
    required String userId,
    required String accessToken,
  }) async {
    if (_connected && _userId == userId) {
      debugPrint('[STOMP] ✅ Already connected');
      return;
    }

    // Validate inputs
    if (userId.isEmpty || accessToken.isEmpty) {
      debugPrint('[STOMP] ❌ Invalid userId or token');
      return;
    }

    _userId = userId;
    _token = accessToken;
    _reconnectAttempts = 0;

    await _initializeConnection();
  }

  Future<void> _initializeConnection() async {
    try {
      // Đóng kết nối cũ nếu có
      if (_stompClient?.connected == true) {
        _stompClient?.deactivate();
      }

      final wsUrl = "https://api.labodc.id.vn/ws";
      debugPrint('[STOMP] 🔄 Connecting to $wsUrl (attempt ${_reconnectAttempts + 1})');
      debugPrint('[STOMP] 🔑 Token: ${_token?.substring(0, 20)}...');
      debugPrint('[STOMP] 👤 UserId: $_userId');

      _stompClient = StompClient(
        config: StompConfig.sockJS(
          url: wsUrl,

          stompConnectHeaders: {
            'Authorization': 'Bearer $_token',
            'accept-version': '1.0,1.1,1.2',
          },

          webSocketConnectHeaders: {
            // 'Authorization': 'Bearer $_token',
          },

          onConnect: _onConnect,

          beforeConnect: () async {
            debugPrint('[STOMP] ⏳ Before connect - waiting 200ms...');
            await Future.delayed(const Duration(milliseconds: 200));
          },

          onStompError: (frame) {
            debugPrint('[STOMP] ❌ STOMP Error:');
            debugPrint('  Command: ${frame.command}');
            debugPrint('  Headers: ${frame.headers}');
            debugPrint('  Body: ${frame.body}');
            _handleConnectionError('STOMP Error: ${frame.body}');
          },

          onWebSocketError: (dynamic err) {
            debugPrint('[STOMP] ❌ WebSocket Error: $err');

            // ✅ FIX 3: Parse error để biết chính xác lỗi gì
            if (err.toString().contains('500')) {
              debugPrint('[STOMP] ' + err.toString());
              debugPrint('[STOMP] 💡 Server returned 500 - possible auth issue');
              debugPrint('[STOMP] 💡 Check if token is valid and not expired');
            } else if (err.toString().contains('401')) {
              debugPrint('[STOMP] 🔐 Unauthorized - token invalid or expired');
            } else if (err.toString().contains('403')) {
              debugPrint('[STOMP] 🚫 Forbidden - insufficient permissions');
            }

            _handleConnectionError('WebSocket Error: $err');
          },

          onDisconnect: (frame) {
            _connected = false;
            debugPrint('[STOMP] 🔴 Disconnected');
            if (frame != null) {
              debugPrint('  Reason: ${frame.body}');
            }
            _scheduleReconnect();
          },

          onWebSocketDone: () {
            debugPrint('[STOMP] 🔴 WebSocket connection closed cleanly');
            _connected = false;
            _scheduleReconnect();
          },

          // ✅ FIX 4: Tăng heartbeat để tránh timeout
          heartbeatIncoming: const Duration(seconds: 20),
          heartbeatOutgoing: const Duration(seconds: 20),

          // ✅ FIX 5: Tăng connection timeout
          connectionTimeout: const Duration(seconds: 15),

          // ✅ FIX 6: Enable debug mode để xem chi tiết
          onDebugMessage: (message) {
            debugPrint('[STOMP-DEBUG] $message');
          },
        ),
      );

      _stompClient!.activate();

    } catch (e, stackTrace) {
      debugPrint('[STOMP] ❌ Connection initialization error: $e');
      debugPrint('[STOMP] Stack trace: $stackTrace');
      _handleConnectionError(e.toString());
    }
  }

  void _onConnect(StompFrame frame) {
    _connected = true;
    _reconnectAttempts = 0;
    debugPrint('[STOMP] ✅ Connected successfully!');
    debugPrint('[STOMP] 📋 Connection frame:');
    debugPrint('  Command: ${frame.command}');
    debugPrint('  Headers: ${frame.headers}');
    debugPrint('  Body: ${frame.body}');

    try {
      final dest = '/user/$_userId/queue/notifications';
      debugPrint('[STOMP] 📡 Subscribing to: $dest');

      _stompClient?.subscribe(
        destination: dest,
        callback: (msg) {
          debugPrint('[STOMP] 📨 Received message:');
          debugPrint('  Destination: ${msg.headers['destination']}');
          debugPrint('  Body: ${msg.body}');

          if (msg.body == null) {
            debugPrint('[STOMP] ⚠️ Message body is null');
            return;
          }

          try {
            final data = jsonDecode(msg.body!);
            final notif = NotificationModel.fromJson(data);
            _controller.add([notif]);
            debugPrint('[STOMP] ✅ Parsed notification: ${notif.title}');
          } catch (e, stackTrace) {
            debugPrint('[STOMP] ❌ JSON Parse Error: $e');
            debugPrint('[STOMP] Stack trace: $stackTrace');
            debugPrint('[STOMP] Raw body: ${msg.body}');
          }
        },
      );

      debugPrint('[STOMP] ✅ Subscription successful');

    } catch (e, stackTrace) {
      debugPrint('[STOMP] ❌ Subscription error: $e');
      debugPrint('[STOMP] Stack trace: $stackTrace');
    }
  }

  void markAsRead(String notificationRecipientId) {
    if (_stompClient?.connected != true) {
      debugPrint('[STOMP] ⚠️ Cannot mark as read: not connected');
      return;
    }

    if (_userId == null) {
      debugPrint('[STOMP] ⚠️ Cannot mark as read: userId is null');
      return;
    }

    try {
      final dest = '/app/users/$_userId/notifications/$notificationRecipientId/read';
      debugPrint('[STOMP] 📤 Sending mark-as-read to: $dest');

      _stompClient?.send(
        destination: dest,
        headers: {
          'Authorization': 'Bearer $_token',
          'content-type': 'application/json',
        },
      );


      debugPrint('[STOMP] ✅ Mark-as-read sent successfully');
    } catch (e, stackTrace) {
      debugPrint('[STOMP] ❌ Mark as read error: $e');
      debugPrint('[STOMP] Stack trace: $stackTrace');
    }
  }

  void _handleConnectionError(String error) {
    debugPrint('[STOMP] ⚠️ Handling connection error: $error');

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[STOMP] ❌ Max reconnection attempts reached. Giving up.');
      debugPrint('[STOMP] 💡 Possible solutions:');
      debugPrint('   1. Check if access token is valid and not expired');
      debugPrint('   2. Verify server logs for authentication errors');
      debugPrint('   3. Check if userId is correct');
      debugPrint('   4. Try refreshing the token and reconnecting');
      _connected = false;
      return;
    }

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[STOMP] ⛔ Max reconnection attempts reached');
      return;
    }

    if (_userId == null || _token == null) {
      debugPrint('[STOMP] ⚠️ Cannot reconnect: missing credentials');
      return;
    }

    // Exponential backoff: 2, 4, 8 seconds
    final delaySeconds = (2 << _reconnectAttempts).clamp(2, 8);
    _reconnectAttempts++;

    debugPrint('[STOMP] 🔄 Scheduling reconnect in $delaySeconds seconds');
    debugPrint('[STOMP]    (attempt $_reconnectAttempts/$_maxReconnectAttempts)');

    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_connected) {
        debugPrint('[STOMP] 🔄 Executing reconnection...');
        _initializeConnection();
      }
    });
  }

  void disconnect() {
    debugPrint('[STOMP] 🔌 Disconnecting...');
    _reconnectTimer?.cancel();
    _connected = false;
    _reconnectAttempts = 0;

    try {
      if (_stompClient?.connected == true) {
        _stompClient?.deactivate();
      }
      debugPrint('[STOMP] ✅ Disconnected successfully');
    } catch (e) {
      debugPrint('[STOMP] ⚠️ Disconnect error: $e');
    }
  }

  // Reset service khi token mới
  Future<void> reconnectWithNewToken(String userId, String accessToken) async {
    debugPrint('[STOMP] 🔄 Reconnecting with new token...');
    debugPrint('[STOMP] 👤 UserId: $userId');
    debugPrint('[STOMP] 🔑 New token: ${accessToken.substring(0, 20)}...');

    disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await connect(userId: userId, accessToken: accessToken);
  }

  void dispose() {
    debugPrint('[STOMP] 🗑️ Disposing service...');
    _reconnectTimer?.cancel();
    disconnect();
    _controller.close();
  }
}