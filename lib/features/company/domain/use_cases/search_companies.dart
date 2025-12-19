import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../shared/models/search_request_model.dart';
import '../entities/paginated_company_entity.dart';
import '../repositories/company_repository.dart';

class SearchCompanies implements UseCase<PaginatedCompanyEntity, SearchCompaniesParams> {
  final CompanyRepository repository;

  SearchCompanies(this.repository);

  @override
  Future<Either<Failure, PaginatedCompanyEntity>> call(SearchCompaniesParams params) async {
    return await repository.searchCompanies(params.request);
  }
}

class SearchCompaniesParams {
  final SearchRequest request;

  SearchCompaniesParams({required this.request});
}