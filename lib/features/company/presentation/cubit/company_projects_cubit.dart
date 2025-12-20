// lib/features/company/presentation/cubit/company_projects_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/company_project_model.dart';
import '../../domain/repositories/company_repository.dart';

abstract class CompanyProjectsState {}
class CompanyProjectsInitial extends CompanyProjectsState {}
class CompanyProjectsLoading extends CompanyProjectsState {}
class CompanyProjectsLoaded extends CompanyProjectsState {
  final List<CompanyProjectModel> projects;
  CompanyProjectsLoaded(this.projects);
}
class CompanyProjectsError extends CompanyProjectsState {
  final String message;
  CompanyProjectsError(this.message);
}

class CompanyProjectsCubit extends Cubit<CompanyProjectsState> {
  final CompanyRepository repository;
  CompanyProjectsCubit({required this.repository}) : super(CompanyProjectsInitial());

  Future<void> fetchProjects(String companyId) async {
    emit(CompanyProjectsLoading());
    final result = await repository.getProjectsByCompany(companyId);
    result.fold(
          (failure) => emit(CompanyProjectsError(failure.message)),
          (projects) => emit(CompanyProjectsLoaded(projects)),
    );
  }
}