import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> fetchNotifications({
    required String userId,
    String? token,
  });

  Future<Either<Failure, int>> getUnreadCount({
    required String userId,
    String? token,
  });

  Future<Either<Failure, void>> markAsRead({
    required String userId,
    required String notificationRecipientId,
    String? token,
  });

  Future<Either<Failure, void>> registerDeviceToken({
    required String userId,
    required String deviceToken,
    required String platform,
    String? authToken,
  });
}