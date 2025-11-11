import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/realtime/stomp_notification_service.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/repositories_impl/notification_repository_impl.dart';
import '../../../../core/error/failures.dart';

class WebSocketNotificationCubit extends Cubit<List<NotificationEntity>> {
  final NotificationRepositoryImpl repository;
  final StompNotificationService stompService;
  final String userId;
  StreamSubscription? _stompSub;
  final AuthProvider auth;
  bool _isInitialized = false;

  WebSocketNotificationCubit(
      this.repository,
      this.stompService,
      this.userId,
      this.auth,
      ) : super([]);

  Future<void> init({String? token}) async {
    if (_isInitialized) {
      print('⚠️ Already initialized');
      return;
    }

    // Validate inputs
    if (userId.isEmpty) {
      print('❌ Cannot initialize: empty userId');
      return;
    }

    final accessToken = token ?? auth.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      print('❌ Cannot initialize: empty access token');
      return;
    }

    try {
      print('🔄 Initializing WebSocketNotificationCubit for user: $userId');

      // 1. Fetch existing notifications first
      final result = await repository.fetchNotifications(
        userId: userId,
        token: accessToken,
      );

      result.fold(
            (failure) {
          print("❌ Fetch notifications error: ${failure.message}");
          // Không emit state nếu lỗi, giữ state rỗng
        },
            (data) {
          print("✅ Fetched ${data.length} notifications");
          emit(data);
        },
      );

      // 2. Connect to WebSocket
      print('🔄 Connecting to WebSocket...');
      await stompService.connect(
        userId: userId,
        accessToken: accessToken,
      );

      // 3. Subscribe to notification stream
      _stompSub = stompService.notificationsStream.listen(
            (dynamic payload) {
          try {
            if (payload is NotificationEntity) {
              // Single notification
              final updated = [payload, ...state];
              emit(updated);
              print('📩 Added new notification: ${payload.title}');
            } else if (payload is List<NotificationEntity>) {
              // Multiple notifications
              final updated = [...payload, ...state];
              emit(updated);
              print('📩 Added ${payload.length} notifications');
            } else if (payload is List) {
              // Try to cast list items
              final notifications = payload
                  .whereType<NotificationEntity>()
                  .toList();
              if (notifications.isNotEmpty) {
                final updated = [...notifications, ...state];
                emit(updated);
                print('📩 Added ${notifications.length} notifications');
              }
            }
          } catch (e, stackTrace) {
            print('❌ Payload handling error: $e');
            print('Stack trace: $stackTrace');
          }
        },
        onError: (error) {
          print('❌ Stream error: $error');
        },
        onDone: () {
          print('⚠️ Stream closed');
        },
      );

      _isInitialized = true;
      print('✅ WebSocketNotificationCubit initialized successfully');
    } catch (e, stackTrace) {
      print('❌ WebSocketNotificationCubit init error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> markAsRead(
      String notificationRecipientId, {
        String? token,
      }) async {
    try {
      final accessToken = token ?? auth.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        print('⚠️ Cannot mark as read: empty access token');
        return;
      }

      print('🔄 Marking notification as read: $notificationRecipientId');

      final res = await repository.markAsRead(
        userId: userId,
        notificationRecipientId: notificationRecipientId,
        token: accessToken,
      );

      res.fold(
            (failure) {
          print('❌ markAsRead API failure: ${failure.message}');
        },
            (_) {
          print('✅ Marked as read successfully');

          // Update local state
          final updated = state
              .map((n) => n.notificationRecipientId == notificationRecipientId
              ? n.copyWith(readStatus: true)
              : n)
              .toList();
          emit(updated);

          // Notify server via WebSocket
          try {
            stompService.markAsRead(notificationRecipientId);
          } catch (e) {
            print('⚠️ WebSocket markAsRead error: $e');
          }
        },
      );
    } catch (e, stackTrace) {
      print('❌ markAsRead failed: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> refresh({String? token}) async {
    try {
      final accessToken = token ?? auth.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        print('⚠️ Cannot refresh: empty access token');
        return;
      }

      print('🔄 Refreshing notifications...');

      final result = await repository.fetchNotifications(
        userId: userId,
        token: accessToken,
      );

      result.fold(
            (failure) => print("❌ Refresh error: ${failure.message}"),
            (data) {
          emit(data);
          print("✅ Refreshed ${data.length} notifications");
        },
      );
    } catch (e) {
      print('❌ Refresh failed: $e');
    }
  }

  // Reconnect khi có token mới (sau khi refresh token)
  Future<void> reconnect({String? newToken}) async {
    final accessToken = newToken ?? auth.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      print('⚠️ Cannot reconnect: empty access token');
      return;
    }

    print('🔄 Reconnecting with new token...');
    try {
      await stompService.reconnectWithNewToken(userId, accessToken);
    } catch (e) {
      print('❌ Reconnect error: $e');
    }
  }

  @override
  Future<void> close() async {
    print('🔄 Closing WebSocketNotificationCubit...');
    try {
      await _stompSub?.cancel();
      stompService.disconnect();
    } catch (e) {
      print('⚠️ Close error: $e');
    }
    return super.close();
  }
}