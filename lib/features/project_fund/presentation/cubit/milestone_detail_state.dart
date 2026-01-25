import 'package:equatable/equatable.dart';
import '../../../milestone/data/models/milestone_member_model.dart';
import '../../../milestone/data/models/milestone_wallet_model.dart';

class MilestoneDetailState extends Equatable {
  final bool isLoading;
  final List<MilestoneMemberModel> members;
  final MilestoneWalletModel? wallet;
  final String? errorMessage;

  const MilestoneDetailState({
    this.isLoading = false,
    this.members = const [],
    this.wallet,
    this.errorMessage,
  });

  MilestoneDetailState copyWith({
    bool? isLoading,
    List<MilestoneMemberModel>? members,
    MilestoneWalletModel? wallet,
    String? errorMessage,
    bool clearError = false,
    bool clearWallet = false,
  }) {
    return MilestoneDetailState(
      isLoading: isLoading ?? this.isLoading,
      members: members ?? this.members,
      wallet: clearWallet ? null : (wallet ?? this.wallet),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, members, wallet, errorMessage];
}
