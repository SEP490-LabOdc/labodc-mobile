// lib/features/user_profile/presentation/cubit/user_profile_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/user_profile_model.dart';
import '../../domain/repositories/user_profile_repository.dart';
import 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserProfileRepository repository;
  final String userId;

  UserProfileCubit({
    required this.repository,
    required this.userId,
  }) : super(UserProfileState.initial());

  Future<void> fetchUserProfile() async {
    emit(
      state.copyWith(
        status: UserProfileStatus.loading,
        errorMessage: null,
      ),
    );

    final result = await repository.getUserProfile(userId);

    result.fold(
          (failure) {
        if (kDebugMode) {
          debugPrint('[UserProfileCubit] failure: ${failure.message}');
        }
        emit(
          state.copyWith(
            status: UserProfileStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
          (user) {
        if (kDebugMode) {
          debugPrint('[UserProfileCubit] success: ${user.id}');
        }
        emit(
          state.copyWith(
            status: UserProfileStatus.success,
            user: user,
          ),
        );
      },
    );
  }

  /// Gọi sau khi EditProfilePage lưu thành công & pop về
  void updateLocalUser(UserProfileModel newUser) {
    emit(
      state.copyWith(
        status: UserProfileStatus.success,
        user: newUser,
        errorMessage: null,
      ),
    );
  }
}
