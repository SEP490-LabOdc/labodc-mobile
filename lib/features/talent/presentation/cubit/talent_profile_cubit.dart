// lib/features/talent/presentation/cubit/talent_profile_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/provider/auth_provider.dart';
import 'talent_profile_state.dart';
import '../../domain/use_cases/get_talent_profile.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/talent_entity.dart';


class TalentProfileCubit extends Cubit<TalentProfileState> {
  final GetTalentProfile getTalentProfile;
  final AuthProvider authProvider;

  TalentProfileCubit({required this.getTalentProfile, required this.authProvider})
      : super(TalentProfileState.initial()) {
    if (authProvider.isAuthenticated && authProvider.userId.isNotEmpty) {
      fetchProfile();
    }
  }

  Future<void> fetchProfile() async {
    final token = authProvider.accessToken;
    final userId = authProvider.userId;

    if (token == null || token.isEmpty) {
      emit(state.copyWith(
        status: TalentProfileStatus.error,
        errorMessage: "Không có Token truy cập. Vui lòng đăng nhập lại.",
      ));
      return;
    }

    if (userId.isEmpty) {
      emit(state.copyWith(
        status: TalentProfileStatus.error,
        errorMessage: "Không tìm thấy ID người dùng. Vui lòng đăng nhập lại.",
      ));
      return;
    }

    // Đảm bảo xóa lỗi cũ khi bắt đầu load
    emit(state.copyWith(status: TalentProfileStatus.loading, errorMessage: null));

    try {
      // ✅ ĐÃ SỬA: Gọi Use Case chuyên biệt getTalentProfile
      final TalentEntity talent = await getTalentProfile(token, userId);

      emit(state.copyWith(
        status: TalentProfileStatus.success,
        user: talent, // Lưu TalentEntity vào trường user
      ));
    } on UnAuthorizedFailure {
      emit(state.copyWith(
        status: TalentProfileStatus.error,
        errorMessage: "Phiên xác thực đã hết hạn. Vui lòng đăng nhập lại.",
      ));
    } on NetworkFailure catch (f) {
      emit(state.copyWith(
        status: TalentProfileStatus.error,
        errorMessage: f.message,
      ));
    } on ServerFailure {
      emit(state.copyWith(
        status: TalentProfileStatus.error,
        errorMessage: "Không thể kết nối đến máy chủ. Vui lòng thử lại sau.",
      ));
    } on Failure catch (f) {
      emit(state.copyWith(
        status: TalentProfileStatus.error,
        errorMessage: f.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TalentProfileStatus.error,
        errorMessage: "Lỗi không xác định khi tải hồ sơ: $e",
      ));
    }
  }
}