import '../../domain/entities/project_entity.dart';

class RelatedProjectsPreviewState {
  final bool isLoading;
  final List<ProjectEntity> projects;
  final String? errorMessage;

  RelatedProjectsPreviewState({
    required this.isLoading,
    required this.projects,
    this.errorMessage,
  });

  factory RelatedProjectsPreviewState.initial() =>
      RelatedProjectsPreviewState(
        isLoading: true,
        projects: const [],
        errorMessage: null,
      );

  RelatedProjectsPreviewState copyWith({
    bool? isLoading,
    List<ProjectEntity>? projects,
    String? errorMessage,
  }) {
    return RelatedProjectsPreviewState(
      isLoading: isLoading ?? this.isLoading,
      projects: projects ?? this.projects,
      errorMessage: errorMessage,
    );
  }
}
