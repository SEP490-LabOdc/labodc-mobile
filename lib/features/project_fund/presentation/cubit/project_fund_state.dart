import 'package:equatable/equatable.dart';
import 'package:labodc_mobile/features/project_application/data/models/my_project_model.dart';
import 'package:labodc_mobile/features/milestone/data/models/project_milestone_model.dart';

class ProjectFundState extends Equatable {
  final List<MyProjectModel> projects;
  final MyProjectModel? selectedProject;
  final List<ProjectMilestoneModel> milestones;

  final double holdingAmount;
  final double distributedAmount;

  final bool isLoadingProjects;
  final bool isLoadingMilestones;
  final String? errorMessage;

  const ProjectFundState({
    this.projects = const [],
    this.selectedProject,
    this.milestones = const [],
    this.holdingAmount = 0,
    this.distributedAmount = 0,
    this.isLoadingProjects = false,
    this.isLoadingMilestones = false,
    this.errorMessage,
  });

  bool get isInitialLoading =>
      isLoadingProjects && projects.isEmpty && milestones.isEmpty;

  ProjectFundState copyWith({
    List<MyProjectModel>? projects,
    MyProjectModel? selectedProject,
    List<ProjectMilestoneModel>? milestones,
    double? holdingAmount,
    double? distributedAmount,
    bool? isLoadingProjects,
    bool? isLoadingMilestones,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProjectFundState(
      projects: projects ?? this.projects,
      selectedProject: selectedProject ?? this.selectedProject,
      milestones: milestones ?? this.milestones,
      holdingAmount: holdingAmount ?? this.holdingAmount,
      distributedAmount: distributedAmount ?? this.distributedAmount,
      isLoadingProjects: isLoadingProjects ?? this.isLoadingProjects,
      isLoadingMilestones: isLoadingMilestones ?? this.isLoadingMilestones,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    projects,
    selectedProject,
    milestones,
    holdingAmount,
    distributedAmount,
    isLoadingProjects,
    isLoadingMilestones,
    errorMessage,
  ];
}
