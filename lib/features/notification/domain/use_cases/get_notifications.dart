import '../repositories/notification_repository.dart';
import '../entities/notification_entity.dart';

class GetNotifications {
  final NotificationRepository repository;
  GetNotifications(this.repository);
  Future<List<NotificationEntity>> call(String token, String userId) async {
    return await repository.getNotifications(token, userId);
  }
}
