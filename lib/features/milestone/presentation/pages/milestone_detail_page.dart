import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';
import '../../../../shared/widgets/network_image_with_fallback.dart';
import '../../../../shared/widgets/expandable_text.dart';
import '../../../milestone/domain/enums/project_milestone_status.dart';

import '../../../report/presentation/widgets/milestone_report_list.dart';
import '../cubit/milestone_detail_cubit.dart';
import '../cubit/milestone_detail_state.dart';
import '../widgets/milestone_disbursement_tab.dart';
import '../widgets/milestone_documents_tab.dart';

class MilestoneDetailPage extends StatelessWidget {
  final String milestoneId;

  const MilestoneDetailPage({super.key, required this.milestoneId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.primary;
    final Color textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;
    return BlocProvider(
      create: (context) =>
          getIt<MilestoneDetailCubit>()..loadMilestoneDetail(milestoneId),
      child: BlocBuilder<MilestoneDetailCubit, MilestoneDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.error != null) {
            return Scaffold(
              appBar: AppBar(title: const Text("Chi tiết")),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.milestone == null) {
            return const Scaffold(
              body: Center(child: Text("Không tìm thấy dữ liệu")),
            );
          }

          final m = state.milestone!;

          return DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  m.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                elevation: 0,
                bottom: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: textColor,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: theme.primaryColor,
                  tabs: const [
                    Tab(text: "Tổng quan"),
                    Tab(text: "Báo cáo"),
                    Tab(text: "Tài liệu"),
                    Tab(text: "Phân bổ"),
                  ],
                ),
              ),
              body: Container(
                color: Colors.grey.shade50,
                child: TabBarView(
                  children: [
                    _buildOverview(context, m),
                    MilestoneReportsList(milestoneId: milestoneId),
                    MilestoneDocumentsTab(milestoneId: milestoneId),
                    MilestoneDisbursementTab(milestoneId: milestoneId),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------
  // OVERVIEW SECTION (Đã tối ưu UI/UX)
  // ---------------------------------------------------------
  Widget _buildOverview(BuildContext context, dynamic m) {
    // Kiểm tra quá hạn
    final status = ProjectMilestoneStatus.fromString(m.status);
    final isOverdue =
        m.endDate.isBefore(DateTime.now()) &&
        status != ProjectMilestoneStatus.COMPLETED &&
        status != ProjectMilestoneStatus.PAID;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. INFO CARD (Title, Status, Date, Budget)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Status Badge & Overdue Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusBadge(m.status),
                    if (isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Text(
                          "Quá hạn",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  m.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),

                // Info Rows
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: "Thời gian",
                  value:
                      "${ProjectDataFormatter.formatDate(m.startDate)} - ${ProjectDataFormatter.formatDate(m.endDate)}",
                  valueColor: Colors.black87,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.monetization_on_outlined,
                  label: "Ngân sách",
                  value: ProjectDataFormatter.formatCurrency(context, m.budget),
                  valueColor: Colors.green.shade700,
                  isBold: true,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),

                // Description
                const Text(
                  "Mô tả chi tiết",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ExpandableText(
                  text: m.description,
                  maxLines: 6,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. TALENTS LIST
          if (m.talents != null && (m.talents as List).isNotEmpty)
            _membersSection("Thành viên tham gia", m.talents),

          const SizedBox(height: 24),

          // 3. MENTORS LIST
          if (m.mentors != null && (m.mentors as List).isNotEmpty)
            _membersSection("Giảng viên hướng dẫn", m.mentors),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // HELPERS (UI Components)
  // ---------------------------------------------------------

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.black,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    // Sử dụng formatter mới
    final color = ProjectDataFormatter.getMilestoneStatusColor(status);
    final label = ProjectDataFormatter.translateMilestoneStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _membersSection(String label, List users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            separatorBuilder: (ctx, index) => Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.grey.shade100,
              indent: 70,
            ),
            itemBuilder: (context, index) {
              final u = users[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: NetworkImageWithFallback(
                      imageUrl: u["avatar"] ?? "",
                      width: 44,
                      height: 44,
                      fallbackIcon: Icons.person,
                    ),
                  ),
                ),
                title: Text(
                  u["name"] ?? "Không rõ",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: u["email"] != null
                    ? Text(
                        u["email"],
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
