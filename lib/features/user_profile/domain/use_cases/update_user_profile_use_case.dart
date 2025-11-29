import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/user_profile_model.dart';
import '../repositories/user_profile_repository.dart';

class UpdateUserProfileUseCase {
  final UserProfileRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfileModel>> call(
      UserProfileModel profile,
      ) {
    return repository.updateUserProfile(profile);
  }
}
