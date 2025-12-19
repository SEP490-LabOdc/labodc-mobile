import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/project_entity.dart';
import '../entities/paginated_project_entity.dart';
import '../repositories/project_repository.dart';

class GetHiringProjects implements UseCase<PaginatedProjectEntity, GetHiringProjectsParams> {
  final ProjectRepository repository;

  GetHiringProjects(this.repository);

  @override
  Future<Either<Failure, PaginatedProjectEntity>> call(GetHiringProjectsParams params) async {
    return await repository.getHiringProjects(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetHiringProjectsParams {
  final int page;
  final int pageSize;

  GetHiringProjectsParams({required this.page, required this.pageSize});
}