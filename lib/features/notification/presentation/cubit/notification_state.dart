// lib/features/notification/presentation/cubit/notification_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_state.freezed.dart';

@freezed
class NotificationState with _$NotificationState {
  // Trạng thái ban đầu
  const factory NotificationState.initial() = _Initial;

  // Trạng thái đang tải
  const factory NotificationState.loading() = _Loading;

  // Trạng thái tải thành công, sử dụng List<dynamic> để linh hoạt
  const factory NotificationState.loaded(List<dynamic> notifications) = _Loaded;

  // Trạng thái lỗi
  const factory NotificationState.error(String message) = _Error;

  // ✅ TRẠNG THÁI SIDE EFFECT: Nhận tin nhắn FCM foreground (kích hoạt SnackBar)
  const factory NotificationState.newMessageReceived(Map<String, dynamic> message) = _NewMessageReceived;

  // ✅ TRẠNG THÁI SIDE EFFECT: Kích hoạt điều hướng sau khi click thông báo
  const factory NotificationState.navigateTo(String route) = _NavigateTo;
}