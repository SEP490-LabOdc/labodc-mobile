import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/get_it/get_it.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/network_image_with_fallback.dart';
import '../../../../shared/widgets/expandable_text.dart';

import '../../../report/presentation/widgets/milestone_report_list.dart';
import '../cubit/milestone_detail_cubit.dart';
import '../cubit/milestone_detail_state.dart';

class MilestoneDetailPage extends StatelessWidget {
  final String milestoneId;

  const MilestoneDetailPage({super.key, required this.milestoneId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MilestoneDetailCubit>()..loadMilestoneDetail(milestoneId),
      child: BlocBuilder<MilestoneDetailCubit, MilestoneDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.error != null) {
            return Scaffold(body: Center(child: Text(state.error!)));
          }

          final m = state.milestone!;

          return DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: AppBar(
                title: Text(m.title),
                elevation: 0,
                bottom: const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: "Tổng quan"),
                    Tab(text: "Báo cáo & Nghiệm thu"),
                    Tab(text: "Tài liệu"),
                    Tab(text: "Phân bổ"),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _buildOverview(context, m),
                  MilestoneReportsList(milestoneId: milestoneId),
                  Center(child: Text("Không có tài liệu.")),
                  Center(child: Text("Chưa có phân bổ.")),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------
  // OVERVIEW SECTION (tối ưu theo yêu cầu)
  // ---------------------------------------------------------
  Widget _buildOverview(BuildContext context, m) {
    final isOverdue = m.endDate.isBefore(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------------
          // 1. TITLE + DESCRIPTION (đưa lên đầu theo yêu cầu)
          // ---------------------------------------------------------
          ReusableCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ExpandableText(text: m.description, maxLines: 5),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ---------------------------------------------------------
          // 2. DETAIL INFO
          // ---------------------------------------------------------
          ReusableCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chi tiết Milestone",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _rowLabel("Trạng thái:", _statusBadge(m.status)),
                const SizedBox(height: 12),

                _rowLabel(
                  "Ngân sách:",
                  Text(
                    ProjectDataFormatter.formatCurrency(context, m.budget),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),

                _rowLabel(
                  "Ngày bắt đầu:",
                  Text(ProjectDataFormatter.formatDate(m.startDate)),
                ),
                const SizedBox(height: 12),

                _rowLabel(
                  "Ngày kết thúc:",
                  Row(
                    children: [
                      Text(ProjectDataFormatter.formatDate(m.endDate)),
                      if (isOverdue) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Quá hạn",
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ---------------------------------------------------------
          // 3. TALENTS LIST
          // ---------------------------------------------------------
          _membersSection("Thành viên", m.talents),

          const SizedBox(height: 20),

          // ---------------------------------------------------------
          // 4. MENTORS LIST
          // ---------------------------------------------------------
          _membersSection("Giảng viên hướng dẫn", m.mentors),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------

  Widget _rowLabel(String label, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(fontSize: 15)),
        ),
        Expanded(child: value),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final color = ProjectDataFormatter.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.15),
      ),
      child: Text(
        ProjectDataFormatter.translateStatus(status),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _membersSection(String label, List users) {
    return ReusableCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (users.isEmpty)
            Text(
              "Chưa có ${label.toLowerCase()}",
              style: TextStyle(color: Colors.grey.shade600),
            ),

          ...users.map((u) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: NetworkImageWithFallback(
                  imageUrl: u["avatar"] ?? "",
                  width: 42,
                  height: 42,
                ),
              ),
              title: Text(u["name"] ?? "Không rõ"),
              subtitle: Text(u["email"] ?? ""),
            );
          }),
        ],
      ),
    );
  }
}
