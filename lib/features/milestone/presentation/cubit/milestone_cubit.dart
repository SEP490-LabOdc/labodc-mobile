import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/milestone_repository.dart';
import 'milestone_state.dart';

class MilestoneCubit extends Cubit<MilestoneState> {
  final MilestoneRepository repo;

  MilestoneCubit(this.repo) : super(MilestoneState.initial());

  Future<void> loadMilestones(String projectId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await repo.getMilestones(projectId);

    result.fold(
          (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            milestones: [],
          ),
        );
      },
          (list) {
        emit(
          state.copyWith(
            isLoading: false,
            milestones: list,
            errorMessage: null,
          ),
        );
      },
    );
  }
}
