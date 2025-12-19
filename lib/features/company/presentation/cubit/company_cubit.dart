// lib/features/company/presentation/cubit/company_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/core/usecase/usecase.dart';
import '../../domain/use_cases/get_active_companies_use_case.dart';
import 'company_state.dart';



class CompanyCubit extends Cubit<CompanyState> {
  final GetActiveCompaniesUseCase getActiveCompaniesUseCase;

  CompanyCubit({required this.getActiveCompaniesUseCase}) : super(CompanyInitial());

  Future<void> fetchActiveCompanies() async {
    if (state is CompanyLoaded) return;

    emit(CompanyLoading());

    final NoParams params = NoParams();
    final result = await getActiveCompaniesUseCase(params);
    result.fold(
          (failure) => emit(CompanyError(message: failure.message)),
          (companies) => emit(CompanyLoaded(companies: companies)),
    );
  }
}

