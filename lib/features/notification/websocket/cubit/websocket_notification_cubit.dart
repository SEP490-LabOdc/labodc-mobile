import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/notification/data/models/notification_model.dart';
import '../../../../features/notification/domain/entities/notification_entity.dart';
import '../../data/repositories_impl/notification_repository_impl.dart';
import '../../../../core/services/realtime/stomp_notification_service.dart';
import '../../../../core/services/widget/notification_widget_service.dart';

class WebSocketNotificationCubit extends Cubit<List<NotificationEntity>> {
  final NotificationRepositoryImpl repository;
  final StompNotificationService stompService;

  // Lưu Subscription để quản lý
  StreamSubscription? _stompSub;
  String? _currentUserId;

  WebSocketNotificationCubit(this.repository, this.stompService) : super([]);

  Future<void> connect(String userId, String accessToken) async {
    // 1. Luôn load lại API khi hàm này được gọi (để đảm bảo data mới nhất)
    await _fetchInitialNotifications(userId, accessToken);

    // 2. Nếu đã kết nối với đúng user này rồi, KHÔNG connect lại Socket
    // Chỉ cần đảm bảo subscription đang lắng nghe
    if (stompService.isConnected && _currentUserId == userId) {
      debugPrint("⚡ [Cubit] Socket already connected. Skipping reconnect.");
      if (_stompSub == null) _listenToStream(); // Đề phòng subscription bị mất
      return;
    }

    _currentUserId = userId;

    // 3. Kết nối Socket & Lắng nghe
    debugPrint("🚀 [Cubit] Initializing Socket Connection...");

    // Hủy lắng nghe cũ (nếu có)
    await _stompSub?.cancel();

    // Bắt đầu lắng nghe TRƯỚC hoặc SAU khi connect đều được,
    // miễn là cùng 1 instance service.
    _listenToStream();

    await stompService.connect(userId: userId, accessToken: accessToken);
  }

  void _listenToStream() {
    debugPrint("🎧 [Cubit] Start listening to notification stream...");

    // StreamController là broadcast nên có thể listen nhiều lần
    _stompSub = stompService.notificationsStream.listen((notif) {
      debugPrint("🔔 [Cubit] Realtime Notification Received: ${notif.title}");
      _onNotificationReceived(notif);
    });
  }

  void _onNotificationReceived(NotificationEntity notif) {
    // [FIX LỖI UI KHÔNG CẬP NHẬT]
    // Phải tạo ra một List MỚI HOÀN TOÀN (List.of hoặc List.from)
    final currentList = List<NotificationEntity>.of(state);

    // Kiểm tra trùng lặp (nếu mạng lag socket bắn 2 lần)
    final isExist = currentList.any(
      (e) => e.notificationRecipientId == notif.notificationRecipientId,
    );

    if (!isExist) {
      // Thêm vào đầu danh sách
      currentList.insert(0, notif);
      debugPrint(
        "✅ [Cubit] Emitting new state with ${currentList.length} items",
      );
      emit(currentList);
      _updateWidget(); // Update widget với notification mới
    }
  }

  Future<void> _fetchInitialNotifications(String userId, String token) async {
    final result = await repository.fetchNotifications(
      userId: userId,
      token: token,
    );
    result.fold((failure) => debugPrint("❌ API Error: ${failure.message}"), (
      data,
    ) {
      debugPrint("📥 API Fetched ${data.length} items");
      emit(data);
      _updateWidget(); // Update widget sau khi fetch thành công
    });
  }

  Future<void> markAsRead(String notificationRecipientId) async {
    try {
      stompService.markAsRead(notificationRecipientId);
      final updatedList = state.map((n) {
        if (n.notificationRecipientId == notificationRecipientId) {
          return n.copyWith(readStatus: true);
        }
        return n;
      }).toList();
      emit(updatedList);
      _updateWidget(); // Update widget sau khi đánh dấu đã đọc
    } catch (e) {
      debugPrint("❌ Mark read error: $e");
    }
  }

  Future<void> deleteNotification(
    String notificationRecipientId, {
    String? token,
  }) async {
    // Optimistic UI update - remove immediately
    final originalList = List<NotificationEntity>.of(state);
    final updatedList = state
        .where((n) => n.notificationRecipientId != notificationRecipientId)
        .toList();

    emit(updatedList);
    _updateWidget(); // Update widget count immediately

    try {
      final result = await repository.deleteNotification(
        notificationRecipientId: notificationRecipientId,
        token: token,
      );

      result.fold(
        (failure) {
          // Rollback on failure
          debugPrint("❌ Delete notification failed: ${failure.message}");
          emit(originalList);
          _updateWidget();
          throw Exception(failure.message);
        },
        (_) {
          debugPrint("✅ Notification deleted successfully");
        },
      );
    } catch (e) {
      debugPrint("❌ Delete notification error: $e");
      rethrow;
    }
  }

  Future<void> disconnect() async {
    await _stompSub?.cancel();
    _stompSub = null;
    stompService.disconnect();
    _currentUserId = null;
    emit([]);
    await NotificationWidgetService.reset(); // Reset widget khi disconnect
  }

  /// Update widget với số lượng thông báo chưa đọc hiện tại
  Future<void> _updateWidget() async {
    final unreadCount = state.where((n) => !n.readStatus).length;
    await NotificationWidgetService.updateUnreadCount(unreadCount);
  }
}
