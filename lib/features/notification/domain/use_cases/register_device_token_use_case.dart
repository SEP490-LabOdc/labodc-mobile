import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notification_repository.dart';

class RegisterDeviceTokenUseCase {
  final NotificationRepository repository;

  RegisterDeviceTokenUseCase(this.repository);

  /// Đăng ký token thiết bị FCM lên server
  Future<Either<Failure, void>> call({
    required String userId,
    required String deviceToken,
    required String platform,
    String? authToken,
  }) async {
    return repository.registerDeviceToken(
      userId: userId,
      deviceToken: deviceToken,
      platform: platform,
      authToken: authToken,
    );
  }
}
