// lib/features/notification/presentation/cubit/notification_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/presentation/provider/auth_provider.dart'; // Giả sử tồn tại AuthProvider
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository;
  final AuthProvider authProvider;

  NotificationCubit({required this.repository, required this.authProvider})
      : super(NotificationState.initial()) {
    // Tự động load số lượng chưa đọc khi khởi tạo
    if (authProvider.isAuthenticated) {
      fetchUnreadCount();
    }
  }

  // Lấy số lượng thông báo chưa đọc
  Future<void> fetchUnreadCount() async {
    final token = authProvider.accessToken;
    final userId = authProvider.userId;
    if (token == null || token.isEmpty || userId.isEmpty) return;

    try {
      final count = await repository.getUnreadCount(token, userId);
      emit(state.copyWith(unreadCount: count));
    } on Failure catch (_) {
      // Bỏ qua lỗi, giữ nguyên count cũ (thường là 0)
    }
  }

  // Lấy danh sách thông báo
  Future<void> fetchNotifications() async {
    final token = authProvider.accessToken;
    final userId = authProvider.userId;

    if (token == null || token.isEmpty || userId.isEmpty) {
      emit(state.copyWith(status: NotificationStatus.error, errorMessage: "Không có thông tin xác thực."));
      return;
    }

    emit(state.copyWith(status: NotificationStatus.loading, errorMessage: null));

    try {
      final notifications = await repository.getNotifications(token, userId);
      emit(state.copyWith(
        status: NotificationStatus.success,
        notifications: notifications,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(status: NotificationStatus.error, errorMessage: f.message));
    }
  }

  // Đánh dấu 1 thông báo là đã đọc
  Future<void> markAsRead(String notificationId) async {
    final token = authProvider.accessToken;
    if (token == null || token.isEmpty) return;

    try {
      // 1. Cập nhật trên UI trước (Optimistic Update)
      emit(state.updateNotification(id: notificationId, readStatus: true));

      // 2. Gọi API để xác nhận
      await repository.markAsRead(token, notificationId);

      // (Nếu API thành công, trạng thái đã đúng. Không cần làm gì thêm.)

    } on Failure catch (f) {
      // 3. Nếu API thất bại, đảo ngược trạng thái (Rollback - Rất quan trọng)
      final originalNotification = state.notifications.firstWhere((n) => n.id == notificationId);
      emit(state.updateNotification(id: notificationId, readStatus: originalNotification.readStatus));
      // Có thể hiển thị lỗi
      // print("Lỗi đánh dấu đã đọc: ${f.message}");
    }
  }
}