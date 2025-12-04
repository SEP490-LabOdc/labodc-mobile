import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/milestone_repository.dart';
import 'milestone_detail_state.dart';

class MilestoneDetailCubit extends Cubit<MilestoneDetailState> {
  final MilestoneRepository repo;

  MilestoneDetailCubit(this.repo) : super(MilestoneDetailState.initial());

  Future<void> loadMilestoneDetail(String milestoneId) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await repo.getMilestoneDetail(milestoneId);

    result.fold(
          (failure) {
        emit(state.copyWith(
          isLoading: false,
          error: failure.message,
        ));
      },
          (milestone) {
        emit(state.copyWith(
          isLoading: false,
          milestone: milestone,
        ));
      },
    );
  }
}
