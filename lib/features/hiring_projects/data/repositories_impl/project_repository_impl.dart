import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../data_sources/project_remote_data_source.dart';
import '../models/project_detail_model.dart';
import '../models/project_model.dart';

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

  @override
  Future<Either<Failure, ProjectDetailModel>> getProjectDetail(String projectId) async {
    try {
      final remoteData = await remoteDataSource.getProjectDetail(projectId);
      // Thành công trả về Right chứa data
      return Right(remoteData);
    } on ServerException catch (e) {
      // Xử lý các lỗi server trả về
      return Left(ServerFailure(e.message, e.statusCode ?? 500));
    } on NetworkException {
      // Lỗi mất mạng
      return const Left(NetworkFailure());
    } catch (e) {
      // Lỗi không xác định
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  @override
  Future<Either<Failure, PaginatedProjectModel>> getRelatedProjects({
    required String projectId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final remoteData = await remoteDataSource.getRelatedProjects(
        projectId,
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