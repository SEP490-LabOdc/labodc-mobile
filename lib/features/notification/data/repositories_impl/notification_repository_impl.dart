import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../data_sources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NotificationEntity>>> fetchNotifications({
    required String userId,
    String? token,
  }) async {
    try {
      final dynamic models =
          await (remoteDataSource as dynamic).getNotifications(token ?? '', userId);
      final entities = (models as List)
          .map((m) => NotificationEntity(
                notificationRecipientId: m.notificationRecipientId,
                type: m.type,
                title: m.title,
                content: m.content,
                data: m.data,
                category: m.category,
                priority: m.priority,
                deepLink: m.deepLink,
                sentAt: m.createdAt ?? DateTime.now(),
                readStatus: m.readStatus,
              ))
          .toList();
      return Right(entities);
    } on Failure catch (f) {
      return Left(f);
    } catch (e, st) {
      return Left(UnknownFailure('getNotifications error: $e\n$st'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({
    required String userId,
    String? token,
  }) async {
    try {
      final notificationsResult =
          await fetchNotifications(userId: userId, token: token);
      return notificationsResult.fold(
        (failure) => Left(failure),
        (list) {
          final count = list.where((n) => !n.readStatus).length;
          return Right(count);
        },
      );
    } on Failure catch (f) {
      return Left(f);
    } catch (e, st) {
      return Left(UnknownFailure('getUnreadCount error: $e\n$st'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead({
    required String userId,
    required String notificationRecipientId,
    String? token,
  }) async {
    try {
      // Use dynamic invoke to tolerate different remote data source signatures.
      await (remoteDataSource as dynamic).markAsRead(
          userId: userId, notificationRecipientId: notificationRecipientId, token: token);
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e, st) {
      return Left(UnknownFailure('markAsRead error: $e\n$st'));
    }
  }

  @override
  Future<Either<Failure, void>> registerDeviceToken({
    required String userId,
    required String deviceToken,
    required String platform,
    String? authToken,
  }) async {
    try {
      await (remoteDataSource as dynamic).registerDeviceToken(
        token: deviceToken,
        userId: userId,
        platform: platform,
        authToken: authToken,
      );
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e, st) {
      return Left(UnknownFailure('registerDeviceToken error: $e\n$st'));
    }
  }
}
