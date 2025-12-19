// lib/features/company/presentation/cubit/company_detail_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/core/usecase/usecase.dart'; // Cần import NoParams
import '../../domain/use_cases/get_company_detail_use_case.dart';
import 'company_detail_state.dart';

class CompanyDetailCubit extends Cubit<CompanyDetailState> {
  final GetCompanyDetailUseCase getCompanyDetailUseCase;

  CompanyDetailCubit({required this.getCompanyDetailUseCase}) : super(CompanyDetailInitial());

  Future<void> fetchCompanyDetail(String companyId) async {
    if (state is CompanyDetailLoaded && (state as CompanyDetailLoaded).company.id == companyId) return;

    emit(CompanyDetailLoading());

    final result = await getCompanyDetailUseCase(companyId);

    result.fold(
          (failure) => emit(CompanyDetailError(message: failure.message)),
          (company) => emit(CompanyDetailLoaded(company: company)),
    );
  }
}