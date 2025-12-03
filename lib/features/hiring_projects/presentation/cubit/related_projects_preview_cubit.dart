import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import 'related_projects_preview_state.dart';

class RelatedProjectsPreviewCubit extends Cubit<RelatedProjectsPreviewState> {
  final ProjectRepository repository;

  RelatedProjectsPreviewCubit({required this.repository})
      : super(RelatedProjectsPreviewState.initial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) {
      return 'Vui lòng kiểm tra kết nối mạng.';
    }
    return 'Đã xảy ra lỗi không xác định.';
  }

  Future<void> loadPreview(String projectId) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
      ),
    );

    final result = await repository.getRelatedProjects(
      projectId: projectId,
      page: 1,
      pageSize: 10,
    );

    result.fold(
          (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            projects: const [],
            errorMessage: _mapFailureToMessage(failure),
          ),
        );
      },
          (paged) {
        final List<ProjectEntity> items = paged.projects;

        emit(
          state.copyWith(
            isLoading: false,
            projects: items,
            errorMessage: null,
          ),
        );
      },
    );
  }
}
