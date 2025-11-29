import '../../data/models/user_profile_model.dart';

enum UserProfileStatus {
  initial,
  loading,
  success,
  failure,
}

class UserProfileState {
  final UserProfileStatus status;
  final UserProfileModel? user;
  final String? errorMessage;


  const UserProfileState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory UserProfileState.initial() {
    return const UserProfileState(status: UserProfileStatus.initial);
  }

  UserProfileState copyWith({
    UserProfileStatus? status,
    UserProfileModel? user,
    String? errorMessage,
  }) {


    return UserProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
