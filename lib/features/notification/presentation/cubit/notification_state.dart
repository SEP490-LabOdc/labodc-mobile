// lib/features/notification/presentation/cubit/notification_state.dart
import '../../../notification/domain/entities/notification_entity.dart';

enum NotificationStatus { initial, loading, success, error }

class NotificationState {
  final NotificationStatus status;
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final String? errorMessage;

  const NotificationState._({
    required this.status,
    required this.notifications,
    required this.unreadCount,
    this.errorMessage,
  });

  factory NotificationState.initial() => const NotificationState._(
    status: NotificationStatus.initial,
    notifications: [],
    unreadCount: 0,
  );

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? notifications,
    int? unreadCount,
    String? errorMessage,
  }) {
    return NotificationState._(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: errorMessage,
    );
  }

  NotificationState updateNotification({required String id, required bool readStatus}) {
    final newNotifications = notifications.map((noti) {
      return noti.id == id ? noti.copyWith(readStatus: readStatus) : noti;
    }).toList();

    return copyWith(
      notifications: newNotifications,
      unreadCount: readStatus && !notifications.firstWhere((n) => n.id == id).readStatus
          ? unreadCount - 1
          : unreadCount,
    );
  }
}