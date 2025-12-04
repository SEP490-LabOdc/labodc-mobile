import 'package:labodc_mobile/features/milestone/data/models/milestone_detail_model.dart';

class MilestoneDetailState {
  final bool isLoading;
  final MilestoneDetailModel? milestone;
  final String? error;

  MilestoneDetailState({
    required this.isLoading,
    required this.milestone,
    required this.error,
  });

  factory MilestoneDetailState.initial() => MilestoneDetailState(
    isLoading: false,
    milestone: null,
    error: null,
  );

  MilestoneDetailState copyWith({
    bool? isLoading,
    MilestoneDetailModel? milestone,
    String? error,
  }) {
    return MilestoneDetailState(
      isLoading: isLoading ?? this.isLoading,
      milestone: milestone ?? this.milestone,
      error: error,
    );
  }
}
