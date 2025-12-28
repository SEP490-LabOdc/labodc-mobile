// lib/features/user_profile/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/get_it/get_it.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../shared/widgets/reusable_card.dart';

// Import các thành phần liên quan đến Bookmark
import '../../../hiring_projects/domain/entities/project_entity.dart';
import '../../../hiring_projects/presentation/cubit/bookmark_projects_cubit.dart';

import '../../../auth/presentation/provider/auth_provider.dart';
import '../widgets/profile_overview.dart';
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
      case 'MALE': return 'Nam';
      case 'FEMALE': return 'Nữ';
      default: return genderRaw.isNotEmpty ? genderRaw : 'Chưa cập nhật';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final userId = auth.userId ?? "";

    return MultiBlocProvider(
      providers: [
        BlocProvider<UserProfileCubit>(
          create: (context) => UserProfileCubit(
            repository: getIt<UserProfileRepository>(),
            userId: userId,
          )..fetchUserProfile(),
        ),
        // Cung cấp BookmarkProjectsCubit để lấy số lượng đã thích
        BlocProvider<BookmarkProjectsCubit>(
          create: (context) => getIt<BookmarkProjectsCubit>()..loadBookmarks(userId),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Hồ sơ cá nhân",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Cài đặt',
              onPressed: () => context.push(Routes.setting),
            ),
          ],
        ),
        body: BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (context, state) {
            if (state.status == UserProfileStatus.loading ||
                state.status == UserProfileStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == UserProfileStatus.failure) {
              return _buildErrorView(context, state.errorMessage);
            }

            final UserProfileModel user = state.user!;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 1. Phần Overview hiện tại của bạn
                  ProfileOverview(
                    fullName: user.fullName,
                    avatarUrl: user.avatarUrl,
                    roleLabel: user.role,
                    email: user.email,
                    phone: user.phone,
                    birthDateText: _formatDate(user.birthDate),
                    genderText: _mapGender(user.gender),
                    address: user.address,
                    actions: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final updatedUser = await context.push<UserProfileModel>(
                            Routes.editProfile,
                            extra: user,
                          );
                          if (updatedUser != null && context.mounted) {
                            context.read<UserProfileCubit>().updateLocalUser(updatedUser);
                          }
                        },
                        icon: const Icon(Icons.edit_note),
                        label: const Text("Chỉnh sửa hồ sơ"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 2. PHẦN THIẾT KẾ MỚI: DANH SÁCH TIỆN ÍCH (Bookmark nằm ở đây)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hoạt động của tôi",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // Ô bấm Dự án đã lưu (Thiết kế Card tinh tế)
                        _buildMenuTile(
                          context,
                          icon: Icons.favorite_rounded,
                          color: Colors.redAccent,
                          title: "Dự án đã lưu",
                          subtitle: "Các dự án bạn đã đánh dấu quan tâm",
                          trailing: BlocBuilder<BookmarkProjectsCubit, List<ProjectEntity>>(
                            builder: (context, projects) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${projects.length}",
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            context.push('/saved-projects');
                          },
                        ),

                        // Có thể thêm các mục khác trong tương lai như: CV của tôi, Lịch sử ứng tuyển...
                        const SizedBox(height: 8),
                        _buildMenuTile(
                          context,
                          icon: Icons.description_outlined,
                          color: Colors.blueAccent,
                          title: "CV của tôi",
                          subtitle: "Quản lý các bản hồ sơ năng lực",
                          onTap: () {
                            // context.push(Routes.myCvs);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget helper tạo các dòng Menu chuyên nghiệp
  Widget _buildMenuTile(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required String title,
        required String subtitle,
        Widget? trailing,
        required VoidCallback onTap,
      }) {
    return ReusableCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message ?? "Lỗi tải dữ liệu"),
          ElevatedButton(
            onPressed: () => context.read<UserProfileCubit>().fetchUserProfile(),
            child: const Text("Thử lại"),
          ),
        ],
      ),
    );
  }
}