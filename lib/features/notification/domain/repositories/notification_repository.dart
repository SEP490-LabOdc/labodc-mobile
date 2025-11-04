import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications(String token, String userId);
  Future<int> getUnreadCount(String token, String userId);
  Future<void> markAsRead(String token, String notificationId);
  Future<Either<Failure, void>> registerDeviceToken({
    required String userId,
    required String deviceToken,
    required String platform,
    String? authToken,
  });
}