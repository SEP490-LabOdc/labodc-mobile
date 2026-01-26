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
      final models = await remoteDataSource.fetchNotifications(
        userId,
        authToken: token,
      );
      final entities = models.map(_mapToEntity).toList();
      return Right(entities);
    } on Failure catch (f) {
      return Left(f);
    } catch (e, st) {
      return Left(UnknownFailure('fetchNotifications error: $e\n$st'));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>> fetchUnreadNotifications({
    required String userId,
    String? token,
  }) async {
    try {
      final models = await remoteDataSource.fetchUnreadNotifications(
        userId,
        authToken: token,
      );
      final entities = models.map(_mapToEntity).toList();
      return Right(entities);
    } on Failure catch (f) {
      return Left(f);
    } catch (e, st) {
      return Left(UnknownFailure('fetchUnreadNotifications error: $e\n$st'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({
    required String userId,
    String? token,
  }) async {
    try {
      final result = await fetchUnreadNotifications(
        userId: userId,
        token: token,
      );
      return result.fold((f) => Left(f), (list) => Right(list.length));
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
      await remoteDataSource.markAsRead(
        userId: userId,
        notificationRecipientId: notificationRecipientId,
        authToken: token,
      );
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
      await remoteDataSource.registerDeviceToken(
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

  @override
  Future<Either<Failure, void>> deleteNotification({
    required String notificationRecipientId,
    String? token,
  }) async {
    try {
      await remoteDataSource.deleteNotification(
        notificationRecipientId: notificationRecipientId,
        authToken: token,
      );
      return const Right(null);
    } on Failure catch (f) {
      return Left(f);
    } catch (e, st) {
      return Left(UnknownFailure('deleteNotification error: $e\n$st'));
    }
  }

  NotificationEntity _mapToEntity(dynamic m) {
    return NotificationEntity(
      notificationRecipientId: m.notificationRecipientId,
      type: m.type,
      title: m.title,
      content: m.content,
      data: m.data,
      category: m.category,
      priority: m.priority,
      deepLink: m.deepLink,
      sentAt: m.sentAt ?? DateTime.now(),
      readStatus: m.readStatus,
    );
  }
}
