import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';

import '../../../../core/get_it/get_it.dart';
import '../../../notification/presentation/widgets/notification_bell.dart';
import '../../../project_application/presentation/cubit/my_projects_cubit.dart';
import '../../../project_application/domain/repositories/project_application_repository.dart';

import '../../../project_application/presentation/widgets/my_projects_section.dart';
import 'candidate_list_page.dart';
import 'mentor_approvals_page.dart';
import 'mentor_chat_page.dart';


class MentorDashboardPage extends StatelessWidget {
  const MentorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const String userName = 'Mentor'; // TODO: load tên thật từ Auth

    return Scaffold(
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

          Text(
            'Hành động nhanh',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(context),
          const SizedBox(height: 32),

          MyProjectsSection(
            title: "Dự án của tôi",
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
                      horizontal: 12,
                      vertical: 6,
                    ),
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
