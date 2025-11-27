import 'package:dartz/dartz.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // 1. Import thư viện
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/project_application_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class ApplyProjectParams {
  final String projectId;
  final String cvUrl;
  ApplyProjectParams({required this.projectId, required this.cvUrl});
}

class ApplyProjectUseCase implements UseCase<void, ApplyProjectParams> {
  final ProjectApplicationRepository repository;
  final AuthRepository authRepository;

  ApplyProjectUseCase({
    required this.repository,
    required this.authRepository,
  });

  @override
  Future<Either<Failure, void>> call(ApplyProjectParams params) async {
    try {

      final token = await authRepository.getSavedToken();

      if (token == null || token.isEmpty) {
        return const Left(UnAuthorizedFailure('Chưa đăng nhập. Không tìm thấy token.'));
      }

      if (JwtDecoder.isExpired(token)) {

        return const Left(UnAuthorizedFailure('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'));
      }

      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);


      final userId = decodedToken['userId'] as String?;

      if (userId == null || userId.isEmpty) {
        return const Left(UnAuthorizedFailure('Token không hợp lệ: Không tìm thấy thông tin người dùng.'));
      }

      return repository.applyProject(
        userId: userId,
        projectId: params.projectId,
        cvUrl: params.cvUrl,
      );

    } catch (e) {
      return Left(UnAuthorizedFailure('Lỗi xác thực: ${e.toString()}'));
    }
  }
}