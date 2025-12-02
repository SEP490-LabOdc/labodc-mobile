import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import 'my_projects_state.dart';
import 'package:labodc_mobile/features/project_application/data/models/my_project_model.dart';
import 'package:labodc_mobile/features/project_application/domain/repositories/project_application_repository.dart';
import 'package:labodc_mobile/core/error/failures.dart';

class MyProjectsCubit extends Cubit<MyProjectsState> {
  final ProjectApplicationRepository repository;

  MyProjectsCubit({required this.repository})
      : super(const MyProjectsState());

  Future<void> loadMyProjects({String? status}) async {
    emit(state.copyWith(status: MyProjectsStatus.loading));

    final Either<Failure, List<MyProjectModel>> result =
    await repository.getMyProjects(status: status);

    result.fold(
          (failure) {
        emit(
          state.copyWith(
            status: MyProjectsStatus.failure,
            errorMessage: failure.message ?? 'Đã xảy ra lỗi',
          ),
        );
      },
          (projects) {
        emit(
          state.copyWith(
            status: MyProjectsStatus.success,
            projects: projects,
          ),
        );
      },
    );
  }
}
