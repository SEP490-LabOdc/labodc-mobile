import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../data_sources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  // ===== Lấy danh sách thông báo =====
  @override
  Future<List<NotificationEntity>> getNotifications(String token, String userId) {
    return remoteDataSource.getNotifications(token, userId);
  }

  // ===== Lấy số lượng thông báo chưa đọc =====
  @override
  Future<int> getUnreadCount(String token, String userId) {
    return remoteDataSource.getUnreadCount(token, userId);
  }
  

  // ===== Đăng ký token thiết bị lên server =====
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
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<void> markAsRead(String token, String notificationId) {
    // TODO: implement markAsRead
    throw UnimplementedError();
  }
}
