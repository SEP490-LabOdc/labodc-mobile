// lib/features/company/domain/use_cases/get_active_companies_use_case.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/company_model.dart';
import '../repositories/company_repository.dart';

class GetActiveCompaniesUseCase extends UseCase<List<CompanyModel>, NoParams> {
  final CompanyRepository repository;

  GetActiveCompaniesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CompanyModel>>> call(NoParams params) async {
    return await repository.getActiveCompanies();
  }
}