// lib/features/company/domain/repositories/company_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/search_request_model.dart';
import '../../data/models/company_model.dart';
import '../entities/paginated_company_entity.dart';

abstract class CompanyRepository {
  Future<Either<Failure, List<CompanyModel>>> getActiveCompanies();
  Future<Either<Failure, CompanyModel>> getCompanyDetail(String companyId);
  Future<Either<Failure, PaginatedCompanyEntity>> searchCompanies(SearchRequest request);
}