// lib/features/company/domain/use_cases/get_company_detail_use_case.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/company_model.dart';
import '../repositories/company_repository.dart';

class GetCompanyDetailUseCase extends UseCase<CompanyModel, String> {
  final CompanyRepository repository;

  GetCompanyDetailUseCase(this.repository);

  @override
  Future<Either<Failure, CompanyModel>> call(String companyId) async {
    return await repository.getCompanyDetail(companyId);
  }
}