import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../shared/models/search_request_model.dart';
import '../entities/paginated_project_entity.dart';
import '../repositories/project_repository.dart';

class SearchProjects implements UseCase<PaginatedProjectEntity, SearchProjectsParams> {
  final ProjectRepository repository;

  SearchProjects(this.repository);

  @override
  Future<Either<Failure, PaginatedProjectEntity>> call(SearchProjectsParams params) async {
    return await repository.searchProjects(params.request);
  }
}

class SearchProjectsParams {
  final SearchRequest request;

  SearchProjectsParams({required this.request});
}