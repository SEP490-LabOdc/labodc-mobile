import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';

import '../../../../core/get_it/get_it.dart';
import '../../../notification/presentation/widgets/notification_bell.dart';
import '../../../project_application/data/models/my_project_model.dart';
import '../../../project_application/domain/repositories/project_application_repository.dart';
import '../../../project_application/presentation/cubit/my_projects_cubit.dart';
import '../../../project_application/presentation/cubit/my_projects_state.dart';

// giống bên HiringProjectsPage
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/service_chip.dart';
import '../../../../shared/widgets/expandable_text.dart';

// nếu muốn mở màn chi tiết giống HiringProjectsPage
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_constants.dart';

import 'candidate_list_page.dart';
import 'mentor_approvals_page.dart';
import 'mentor_chat_page.dart';

class MentorDashboardPage extends StatelessWidget {
  const MentorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const String userName = 'Mentor'; // TODO: lấy tên user thực

    return BlocProvider(
      create: (_) => MyProjectsCubit(
        repository: getIt<ProjectApplicationRepository>(),
      )..loadMyProjects(), // gọi API khi vào màn
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: const Text(
            'Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          actions: const [
            NotificationBell(iconSize: 24),
            SizedBox(width: 8),
          ],
        ),
        body: _MentorDashboardBody(userName: userName),
      ),
    );
  }
}

class _MentorDashboardBody extends StatelessWidget {
  final String userName;

  const _MentorDashboardBody({required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, $userName',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 24),

          // ⚡ Hành động nhanh
          Text(
            'Hành động nhanh',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(context),
          const SizedBox(height: 32),

          // 📁 Dự án của tôi
          Text(
            'Dự án của tôi',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          BlocBuilder<MyProjectsCubit, MyProjectsState>(
            builder: (context, state) {
              if (state.status == MyProjectsStatus.loading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state.status == MyProjectsStatus.failure) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    state.errorMessage ?? 'Không thể tải danh sách dự án.',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                );
              }

              if (state.projects.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Bạn chưa tham gia dự án nào.',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }

              // SUCCESS – dùng UI giống HiringProjectsPage
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.projects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final project = state.projects[index];
                  return _MyProjectCard.fromModel(project);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Task cần duyệt',
                count: 5,
                color: Colors.red.shade400,
                icon: Icons.pending_actions,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MentorApprovalsPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                title: 'Ứng viên mới',
                count: 2,
                color: Colors.blue.shade400,
                icon: Icons.person_add,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CandidateListPage(
                        candidateId: 1,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _QuickActionCard(
          title: 'Tin nhắn chưa đọc',
          count: 3,
          color: Colors.green.shade400,
          icon: Icons.message,
          fullWidth: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MentorChatPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;
  final bool fullWidth;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
    this.fullWidth = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyProjectCard extends StatelessWidget {
  final String projectId;
  final String projectName;
  final String description;
  final String status;
  final String? companyName;
  final double? budget;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<dynamic> skills;

  const _MyProjectCard({
    required this.projectId,
    required this.projectName,
    required this.description,
    required this.status,
    required this.skills,
    this.companyName,
    this.budget,
    this.startDate,
    this.endDate,
  });

  factory _MyProjectCard.fromModel(MyProjectModel model) {
    return _MyProjectCard(
      projectId: model.id,
      projectName: model.title,
      description: model.description ?? '',
      status: model.status,
      companyName: model.companyName,
      budget: model.budget,
      startDate: model.startDate,
      endDate: model.endDate,
      skills: model.skills ?? [],
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'N/A';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _formatBudget() {
    if (budget == null) return 'N/A';
    return '\$${budget!.toStringAsFixed(2)}';
  }

  Color _statusColor(BuildContext context) {
    switch (status) {
      case 'PLANNING':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _statusLabel() {
    switch (status) {
      case 'PLANNING':
        return 'Lên kế hoạch';
      case 'IN_PROGRESS':
        return 'Đang thực hiện';
      case 'COMPLETED':
        return 'Hoàn thành';
      default:
        return status;
    }
  }

  String _colorHexFromString(String input) {
    final hash = input.hashCode;
    final colorInt = 0xFFFFFF & hash;
    return '#${colorInt.toRadixString(16).padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statusColor = _statusColor(context);
    final start = _formatDate(startDate);
    final end = _formatDate(endDate);
    final company = companyName ?? 'Không rõ công ty';

    return ReusableCard(
      onTap: () {
        // mở màn chi tiết giống bên HiringProjectsPage
        AppRouter.pushNamed(
          Routes.projectDetailName,
          pathParameters: {'id': projectId},
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề + status pill (gần giống HiringProjects)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  projectName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Tên công ty
          Text(
            company,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),

          // Mô tả rút gọn giống ExpandableText bên HiringProjects
          ExpandableText(
            text: description,
            maxLines: 3,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),

          // Skills → ServiceChip
          if (skills.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills.take(8).map((s) {
                // TODO: thay kiểu cho chuẩn, ở đây giả định s.name là tên skill
                final String name = s.name as String;
                final hex = _colorHexFromString(name);
                return ServiceChip(name: name, color: hex, small: true);
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Từ $start đến $end',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
          if (budget != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Ngân sách: ${_formatBudget()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
