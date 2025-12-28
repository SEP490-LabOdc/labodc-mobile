import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/search_request_model.dart';
import '../../data/models/project_detail_model.dart';
import '../../data/models/project_model.dart';
import '../entities/project_entity.dart';
import '../entities/paginated_project_entity.dart';

abstract class ProjectRepository {
  Future<Either<Failure, PaginatedProjectEntity>> getHiringProjects({
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, PaginatedProjectModel>> getRelatedProjects({
    required String projectId,
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, ProjectDetailModel>> getProjectDetail(String projectId);

  Future<Either<Failure, PaginatedProjectEntity>> searchProjects(SearchRequest request);

  // Local database
  Future<Either<Failure, void>> bookmarkProject(ProjectEntity project, String userId);
  Future<Either<Failure, void>> unbookmarkProject(String projectId, String userId);
  Future<Either<Failure, List<ProjectEntity>>> getBookmarkedProjects(String userId);
  Future<bool> checkIsBookmarked(String projectId, String userId);
}