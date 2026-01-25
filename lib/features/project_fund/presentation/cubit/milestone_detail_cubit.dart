import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../milestone/domain/repositories/milestone_repository.dart';
import 'milestone_detail_state.dart';

class MilestoneDetailCubit extends Cubit<MilestoneDetailState> {
  final MilestoneRepository milestoneRepository;

  MilestoneDetailCubit({required this.milestoneRepository})
    : super(const MilestoneDetailState());

  /// Load milestone detail data
  /// Fetches members (USER role) and wallet information
  Future<void> loadMilestoneDetail(String milestoneId) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // Fetch members by role (USER)
      final membersResult = await milestoneRepository.getMilestoneMembersByRole(
        milestoneId,
        'USER',
      );

      // Fetch wallet info (may return null if not found)
      final walletResult = await milestoneRepository.getMilestoneWallet(
        milestoneId,
      );

      membersResult.fold(
        (failure) {
          emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        },
        (members) {
          walletResult.fold(
            (failure) {
              // Wallet error is not critical, just log and continue
              emit(
                state.copyWith(
                  isLoading: false,
                  members: members,
                  wallet: null,
                ),
              );
            },
            (wallet) {
              emit(
                state.copyWith(
                  isLoading: false,
                  members: members,
                  wallet: wallet,
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể tải dữ liệu: $e',
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
