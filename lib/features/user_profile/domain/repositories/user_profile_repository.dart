import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/user_profile_model.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfileModel>> getUserProfile(String userId);

  Future<Either<Failure, UserProfileModel>> updateUserProfile(
      UserProfileModel profile,
      );
}
