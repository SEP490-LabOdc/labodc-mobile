// lib/features/talent/presentation/cubit/talent_profile_state.dart

import '../../domain/entities/talent_entity.dart';

enum TalentProfileStatus {
  initial,
  loading,
  success,
  error,
}

class TalentProfileState {
  final TalentProfileStatus status;
  final TalentEntity? user;
  final String? errorMessage;

  const TalentProfileState._({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory TalentProfileState.initial() => const TalentProfileState._(status: TalentProfileStatus.initial);

  TalentProfileState copyWith({
    TalentProfileStatus? status,
    TalentEntity? user,
    String? errorMessage,
  }) {
    // Nếu chuyển sang trạng thái error, luôn đảm bảo user là null
    final newUser = status == TalentProfileStatus.error ? null : user ?? this.user;

    return TalentProfileState._(
      status: status ?? this.status,
      user: newUser,
      errorMessage: errorMessage,
    );
  }
}