import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../data_sources/project_remote_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PaginatedProjectEntity>> getHiringProjects({
    required int page,
    required int pageSize,
  }) async {
    try {
      final remoteData = await remoteDataSource.getHiringProjects(
        page: page,
        pageSize: pageSize,
      );
      return Right(remoteData);
    } on ServerException catch (e) {
      final int statusCode = e.statusCode ?? 500;
      switch (statusCode) {
        case 400:
          return Left(InvalidInputFailure(e.message));
        case 401:
          return Left(UnAuthorizedFailure(e.message));
        case 404:
          return Left(NotFoundFailure(e.message));
        default:
          return Left(ServerFailure(e.message, statusCode));
      }
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}