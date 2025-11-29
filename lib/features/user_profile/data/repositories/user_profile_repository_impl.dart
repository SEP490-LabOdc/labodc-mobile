import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/user_profile_model.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_data_source.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;

  UserProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfileModel>> getUserProfile(
      String userId,
      ) async {
    try {
      final model = await remoteDataSource.getUserProfile(userId);
      return Right(model);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      final code = e.statusCode;
      switch (code) {
        case 400:
          return const Left(InvalidInputFailure());
        case 401:
        case 403:
          return const Left(UnAuthorizedFailure());
        case 404:
          return const Left(NotFoundFailure());
        default:
          return Left(ServerFailure(e.message, code ?? 500));
      }
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileModel>> updateUserProfile(
      UserProfileModel profile,
      ) async {
    try {
      final model = await remoteDataSource.updateUserProfile(
        profile.id,
        profile,
      );
      return Right(model);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      final code = e.statusCode;
      switch (code) {
        case 400:
          return const Left(InvalidInputFailure());
        case 401:
        case 403:
          return const Left(UnAuthorizedFailure());
        case 404:
          return const Left(NotFoundFailure());
        default:
          return Left(ServerFailure(e.message, code ?? 500));
      }
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
