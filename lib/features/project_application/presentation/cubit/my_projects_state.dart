import 'package:labodc_mobile/features/project_application/data/models/my_project_model.dart';

enum MyProjectsStatus { initial, loading, success, failure }

class MyProjectsState {
  final MyProjectsStatus status;
  final List<MyProjectModel> projects;
  final String? errorMessage;

  const MyProjectsState({
    this.status = MyProjectsStatus.initial,
    this.projects = const [],
    this.errorMessage,
  });

  MyProjectsState copyWith({
    MyProjectsStatus? status,
    List<MyProjectModel>? projects,
    String? errorMessage,
  }) {
    return MyProjectsState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
