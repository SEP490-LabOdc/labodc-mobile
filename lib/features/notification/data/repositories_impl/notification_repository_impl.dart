import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../data_sources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NotificationEntity>> getNotifications(String token, String userId) {
    return remoteDataSource.getNotifications(token, userId);
  }

  @override
  Future<int> getUnreadCount(String token, String userId) {
    return remoteDataSource.getUnreadCount(token, userId);
  }

  @override
  Future<void> markAsRead(String token, String notificationId) {
    return remoteDataSource.markAsRead(token, notificationId);
  }
}