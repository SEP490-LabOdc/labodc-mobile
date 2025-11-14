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
  final AuthProvider auth;
  bool _isInitialized = false;
  StreamSubscription? _stompSub;

  WebSocketNotificationCubit(
      this.repository,
      this.stompService,
      this.userId,
      this.auth,
      ) : super([]);

  Future<void> init({String? token}) async {
    if (_isInitialized) return;
    final accessToken = token ?? auth.accessToken;
    if (userId.isEmpty || accessToken == null || accessToken.isEmpty) return;

    try {
      final allRes =
      await repository.fetchNotifications(userId: userId, token: accessToken);
      allRes.fold((f) => print("❌ fetchNotifications: ${f.message}"),
              (data) => emit(data));

      await stompService.connect(userId: userId, accessToken: accessToken);
      _stompSub = stompService.notificationsStream.listen((notif) {
        emit([notif, ...state]);
      });

      _isInitialized = true;
    } catch (e) {
      print('❌ WebSocketNotificationCubit init error: $e');
    }
  }

  Future<void> markAsRead(String notificationRecipientId) async {
    try {
      print('🔄 Sending markAsRead via STOMP: $notificationRecipientId');
      stompService.markAsRead(notificationRecipientId);

      // Cập nhật local UI state ngay
      final updated = state
          .map((n) => n.notificationRecipientId == notificationRecipientId
          ? n.copyWith(readStatus: true)
          : n)
          .toList();
      emit(updated);

      print('✅ Marked as read locally (sent via STOMP)');
    } catch (e, st) {
      print('❌ markAsRead via STOMP failed: $e');
      print('Stack trace: $st');
    }
  }



  Future<void> refresh({String? token}) async {
    final accessToken = token ?? auth.accessToken;
    if (accessToken == null || accessToken.isEmpty) return;
    final res = await repository.fetchNotifications(userId: userId, token: accessToken);
    res.fold((f) => print("❌ refresh: ${f.message}"), (data) => emit(data));
  }

  Future<void> reconnect({String? newToken}) async {
    final accessToken = newToken ?? auth.accessToken;
    if (accessToken == null || accessToken.isEmpty) return;
    await stompService.reconnectWithNewToken(userId, accessToken);
  }

  @override
  Future<void> close() async {
    await _stompSub?.cancel();
    stompService.disconnect();
    return super.close();
  }
}
