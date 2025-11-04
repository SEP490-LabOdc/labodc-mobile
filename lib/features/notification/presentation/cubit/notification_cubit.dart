// lib/features/notification/presentation/cubit/notification_cubit.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/notifications/fcm_service.dart';
import '../../../../core/router/route_constants.dart';
import '../../domain/use_cases/get_notifications.dart';
import '../../domain/use_cases/register_device_token_use_case.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  StreamSubscription? _fcmMessageSubscription;
  StreamSubscription? _fcmOpenedAppSubscription;

  final GetNotificationsUseCase _getNotificationsUseCase;
  final RegisterDeviceTokenUseCase _registerDeviceTokenUseCase;
  final String userId;
  final String authToken;

  NotificationCubit({
    required GetNotificationsUseCase getNotificationsUseCase,
    required RegisterDeviceTokenUseCase registerDeviceTokenUseCase,
    required this.userId,
    required this.authToken,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _registerDeviceTokenUseCase = registerDeviceTokenUseCase,
        super(const NotificationState.initial()) {
    _setupFcm();
    _listenToFCM();
    loadNotifications();
  }

  Future<void> _setupFcm() async {
    FcmService.setTokenUploadHandler((token) async {
      final result = await _registerDeviceTokenUseCase.call(
        userId: userId,
        deviceToken: token,
        platform: Platform.isAndroid ? "android" : "ios",
        authToken: authToken,
      );

      result.fold(
            (failure) => debugPrint("❌ Lỗi đăng ký token FCM: ${failure.message}"),
            (_) => debugPrint("✅ Token FCM đã được đăng ký thành công."),
      );
    });

    await FcmService.init();
  }

  void _listenToFCM() {
    _fcmMessageSubscription = FcmService.onMessage.listen((message) {
      debugPrint('[CUBIT] 🔔 FCM Foreground Message Received');
      emit(NotificationState.newMessageReceived(message));
      loadNotifications();
    });

    _fcmOpenedAppSubscription = FcmService.onMessageOpenedApp.listen((message) {
      debugPrint('[CUBIT] 📬 FCM Opened App Message Received');
      final route = message['data']?['route'] ?? '${Routes.labAdmin}/notifications';
      emit(NotificationState.navigateTo(route));
    });
  }

  Future<void> loadNotifications() async {
    emit(const NotificationState.loading());
    final result = await _getNotificationsUseCase.call(
      token: authToken,
      userId: userId,
    );
    result.fold(
          (failure) => emit(NotificationState.error(failure.message)),
          (list) => emit(NotificationState.loaded(list)),
    );
  }

  @override
  Future<void> close() {
    _fcmMessageSubscription?.cancel();
    _fcmOpenedAppSubscription?.cancel();
    debugPrint('[CUBIT] 🔕 FCM Subscriptions canceled.');
    return super.close();
  }
}
