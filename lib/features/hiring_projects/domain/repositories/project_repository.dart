import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/project_detail_model.dart';
import '../entities/project_entity.dart';

abstract class ProjectRepository {
  Future<Either<Failure, PaginatedProjectEntity>> getHiringProjects({
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, ProjectDetailModel>> getProjectDetail(String projectId);
}