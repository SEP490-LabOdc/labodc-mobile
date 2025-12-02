// lib/features/talent/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/get_it/get_it.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/service_chip.dart';

// AuthProvider để lấy userId hiện tại
import '../../../auth/presentation/provider/auth_provider.dart';

// DÙNG CHUNG PROFILE OVERVIEW
import '../widgets/profile_overview.dart';

// DÙNG CHUNG USER PROFILE MODEL + CUBIT + STATE
import '../../data/models/user_profile_model.dart';
import '../cubit/user_profile_cubit.dart';
import '../cubit/user_profile_state.dart';
import '../../domain/repositories/user_profile_repository.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chưa cập nhật';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _mapGender(String genderRaw) {
    switch (genderRaw.toUpperCase()) {
      case 'MALE':
        return 'Nam';
      case 'FEMALE':
        return 'Nữ';
      default:
        return genderRaw.isNotEmpty ? genderRaw : 'Chưa cập nhật';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserProfileCubit>(
      create: (context) {
        final auth = context.read<AuthProvider>();
        final userId = auth.userId;

        final cubit = UserProfileCubit(
          repository: getIt<UserProfileRepository>(),
          userId: userId,
        );

        // Gọi load profile ngay khi tạo
        cubit.fetchUserProfile();
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Hồ sơ Tài năng",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Cài đặt',
              onPressed: () {
                context.push(Routes.setting);
              },
            ),
          ],
        ),
        body: BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (context, state) {
            // ==== LOADING / INITIAL ====
            if (state.status == UserProfileStatus.loading ||
                state.status == UserProfileStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            // ==== ERROR ====
            if (state.status == UserProfileStatus.failure) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ReusableCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tải hồ sơ thất bại",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(state.errorMessage ?? "Lỗi không xác định."),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text("Thử lại"),
                          onPressed: () => context
                              .read<UserProfileCubit>()
                              .fetchUserProfile(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ==== SUCCESS ====
            final UserProfileModel user = state.user!;

            return ProfileOverview(
              fullName: user.fullName,
              avatarUrl: user.avatarUrl,
              roleLabel: user.role,
              email: user.email,
              phone: user.phone,
              birthDateText: _formatDate(user.birthDate),
              genderText: _mapGender(user.gender),
              address: user.address,
              // bio:
              // "Mình là một lập trình viên Flutter, yêu thích xây dựng ứng dụng "
              //     "di động và khám phá công nghệ mới. Trong thời gian rảnh, "
              //     "mình thường đọc sách, nghe nhạc và tham gia các dự án mã nguồn mở.",
              actions: [
                ElevatedButton.icon(
                  onPressed: () async {
                    // Lấy user hiện tại đang hiển thị
                    final currentUser = user;

                    // Push sang trang edit, chờ kết quả trả về
                    final updatedUser = await context.push<UserProfileModel>(
                      Routes.editProfile,
                      extra: currentUser,
                    );

                    // Nếu có user mới trả về thì update lại Cubit -> UI rebuild
                    if (updatedUser != null && context.mounted) {
                      context.read<UserProfileCubit>().updateLocalUser(updatedUser);
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Chỉnh sửa hồ sơ"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
