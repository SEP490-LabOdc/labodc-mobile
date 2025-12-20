import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';
import '../../data/models/company_project_model.dart';

class CompanyProjectMiniCard extends StatelessWidget {
  final CompanyProjectModel project;

  const CompanyProjectMiniCard({
    super.key,
    required this.project,
  });

  String _buildDateRange() {
    final start = ProjectDataFormatter.formatDate(project.startDate);
    final end = ProjectDataFormatter.formatDate(project.endDate);
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dateText = _buildDateRange();
    final skillsText = project.skills.take(3).join(' · ');

    // Lấy màu và text trạng thái
    final statusColor = ProjectDataFormatter.getStatusColor(project.status);
    final statusText = ProjectDataFormatter.translateStatus(project.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Điều hướng đến chi tiết dự án bằng GoRouter
          context.pushNamed(
            Routes.projectDetailName,
            pathParameters: {'id': project.id},
          );
        },
        child: Container(
          width: 260, // Chiều rộng cố định để cuộn ngang đẹp hơn
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.4),
              width: 0.6,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ===== TOP: Title + Status =====
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ===== MID: Ngân sách =====
              Row(
                children: [
                  Icon(Icons.monetization_on_outlined,
                      size: 16, color: theme.primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    ProjectDataFormatter.formatCurrency(context, project.budget),
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              // ===== MID: Thời gian =====
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dateText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ===== BOTTOM: Skills =====
              if (project.skills.isNotEmpty)
                Text(
                  skillsText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}