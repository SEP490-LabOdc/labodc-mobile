// lib/features/talent/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../shared/widgets/expandable_text.dart';
import '../../../../shared/widgets/network_image_with_fallback.dart';
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/service_chip.dart';
import '../../domain/entities/talent_entity.dart';
import '../cubit/talent_profile_cubit.dart';
import '../cubit/talent_profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Hồ sơ Tài năng",
            style: TextStyle(fontWeight: FontWeight.bold)),
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

      body: BlocBuilder<TalentProfileCubit, TalentProfileState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, state),

                const SizedBox(height: 16),

                if (state.status == TalentProfileStatus.success)
                  _buildBasicInfoCard(state.user!),

                const SizedBox(height: 16),

                // Bio / Description (Giữ nguyên hardcode)
                const ReusableCard(
                  child: ExpandableText(
                    text:
                    "Mình là một lập trình viên Flutter, yêu thích xây dựng ứng dụng "
                        "di động và khám phá công nghệ mới. Trong thời gian rảnh, "
                        "mình thường đọc sách, nghe nhạc và tham gia các dự án mã nguồn mở.",
                    maxLines: 3,
                  ),
                ),

                const SizedBox(height: 16),

                // Services / Skills (Giữ nguyên hardcode)
                ReusableCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Kỹ năng & Dịch vụ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          ServiceChip(name: "Flutter", color: "#42A5F5"),
                          ServiceChip(name: "Firebase", color: "#FFCA28"),
                          ServiceChip(name: "REST API", color: "#66BB6A"),
                          ServiceChip(name: "UI/UX Design", color: "#AB47BC"),
                          ServiceChip(name: "Cloud Deployment", color: "#29B6F6"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget mới để hiển thị thông tin cơ bản
  Widget _buildBasicInfoCard(TalentEntity talent) {
    return ReusableCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Thông tin cơ bản",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.email, "Email", talent.email),
          _buildInfoRow(Icons.phone, "Điện thoại", talent.phone),
          _buildInfoRow(Icons.cake, "Ngày sinh", DateFormat('dd/MM/yyyy').format(talent.birthDate)),
          _buildInfoRow(Icons.person, "Giới tính", talent.gender),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // Widget riêng để hiển thị trạng thái Load/Error/Success
  Widget _buildProfileHeader(BuildContext context, TalentProfileState state) {
    if (state.status == TalentProfileStatus.loading || state.status == TalentProfileStatus.initial) {
      return const ReusableCard(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status == TalentProfileStatus.error) {
      return ReusableCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tải hồ sơ thất bại:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 8),
            Text(state.errorMessage ?? "Lỗi không xác định."),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Thử lại"),
                onPressed: () => context.read<TalentProfileCubit>().fetchProfile(),
              ),
            ),
          ],
        ),
      );
    }

    // state.status == TalentProfileStatus.success
    final TalentEntity talent = state.user!;

    return ReusableCard(
      child: Row(
        children: [
          NetworkImageWithFallback(
            imageUrl: talent.avatarUrl.isNotEmpty ? talent.avatarUrl : "https://via.placeholder.com/150",
            width: 80,
            height: 80,
            borderRadius: BorderRadius.circular(40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  talent.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    talent.role.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}