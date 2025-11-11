// lib/features/notification/domain/use_cases/get_notifications.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, List<NotificationEntity>>> call({
    String? token,
    required String userId,
  }) async {
    try {
      // Forward the repository's Either result (repository now returns Either)
      return await repository.fetchNotifications(userId: userId, token: token);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
