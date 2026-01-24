import 'package:dartz/dartz.dart';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/search_request_model.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/paginated_project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../data_sources/project_local_data_source.dart';
import '../data_sources/project_remote_data_source.dart';
import '../models/project_detail_model.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;
  final ProjectLocalDataSource localDataSource;
  final CacheManager<PaginatedProjectEntity> _projectsCache = CacheManager(
    maxSize: 20,
  );

  ProjectRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, PaginatedProjectEntity>> getHiringProjects({
    required int page,
    required int pageSize,
  }) async {
    try {
      // ⚡ Check cache first
      final cacheKey = 'projects_p${page}_s$pageSize';
      final cached = _projectsCache.get(cacheKey);
      if (cached != null) {
        return Right(cached);
      }

      // Fetch from API if not cached
      final remoteData = await remoteDataSource.getHiringProjects(
        page: page,
        pageSize: pageSize,
      );

      // ⚡ Store in cache with 5-minute TTL
      _projectsCache.put(cacheKey, remoteData, ttl: const Duration(minutes: 5));

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
  Future<Either<Failure, ProjectDetailModel>> getProjectDetail(
    String projectId,
  ) async {
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

  @override
  Future<Either<Failure, PaginatedProjectEntity>> searchProjects(
    SearchRequest request,
  ) async {
    try {
      final remoteData = await remoteDataSource.searchProjects(request);
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
  Future<Either<Failure, void>> bookmarkProject(
    ProjectEntity project,
    String userId,
  ) async {
    try {
      final model = ProjectModel(
        projectId: project.projectId,
        projectName: project.projectName,
        description: project.description,
        startDate: project.startDate,
        endDate: project.endDate,
        currentApplicants: project.currentApplicants,
        status: project.status,
        skills: project.skills
            .map(
              (e) => SkillModel(
                id: e.id,
                name: e.name,
                description: e.description,
              ),
            )
            .toList(),
      );
      await localDataSource.saveProject(model, userId);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure("Lỗi lưu dự án vào bộ nhớ tạm."));
    }
  }

  @override
  Future<bool> checkIsBookmarked(String projectId, String userId) =>
      localDataSource.isBookmarked(projectId, userId);

  @override
  Future<Either<Failure, void>> unbookmarkProject(
    String projectId,
    String userId,
  ) async {
    try {
      await localDataSource.removeProject(projectId, userId);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure("Không thể xóa dự án."));
    }
  }

  @override
  Future<Either<Failure, List<ProjectEntity>>> getBookmarkedProjects(
    String userId,
  ) async {
    try {
      final localData = await localDataSource.getSavedProjects(userId);
      return Right(localData);
    } catch (e) {
      return const Left(CacheFailure("Lỗi tải danh sách dự án đã thích."));
    }
  }
}
