import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications(String token, String userId);
  Future<int> getUnreadCount(String token, String userId);
  Future<void> markAsRead(String token, String notificationId);
}