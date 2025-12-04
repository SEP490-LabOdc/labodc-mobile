import '../../data/models/project_milestone_model.dart';

class MilestoneState {
  final bool isLoading;
  final List<ProjectMilestoneModel> milestones;
  final String? errorMessage;

  MilestoneState({
    required this.isLoading,
    required this.milestones,
    this.errorMessage,
  });

  factory MilestoneState.initial() => MilestoneState(
    isLoading: false,
    milestones: const [],
    errorMessage: null,
  );

  MilestoneState copyWith({
    bool? isLoading,
    List<ProjectMilestoneModel>? milestones,
    String? errorMessage,
  }) {
    return MilestoneState(
      isLoading: isLoading ?? this.isLoading,
      milestones: milestones ?? this.milestones,
      errorMessage: errorMessage,
    );
  }
}
