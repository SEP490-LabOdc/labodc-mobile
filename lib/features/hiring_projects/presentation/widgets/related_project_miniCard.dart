import 'package:flutter/material.dart';

import '../../domain/entities/project_entity.dart';
import '../pages/project_detail_page.dart';
import '../utils/project_data_formatter.dart';

class RelatedProjectMiniCard extends StatelessWidget {
  final ProjectEntity project;

  const RelatedProjectMiniCard({
    super.key,
    required this.project,
  });

  String _buildDateRange() {
    return '${ProjectDataFormatter.formatDate(project.startDate)}'
        ' - '
        '${ProjectDataFormatter.formatDate(project.endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dateText = _buildDateRange();
    final skillsText = project.skills
        .take(10)
        .map((s) => s.name)
        .join(' · ');

    // status màu + text Việt hóa
    final statusColor = ProjectDataFormatter.getStatusColor(project.status);
    final statusText = ProjectDataFormatter.translateStatus(project.status);

    return Hero(
      tag: 'related-project-${project.projectId}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailPage(
                  projectId: project.projectId,
                ),
              ),
            );
          },
          child: Container(
            width: 240,
            padding: const EdgeInsets.all(12),
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
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ===== TOP: tên + status chip =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        project.projectName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ===== MID: thời gian =====
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dateText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ===== MID: số lượng ứng viên =====
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${project.currentApplicants} ứng viên',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ===== BOTTOM: skills =====
                if (project.skills.isNotEmpty)
                  Text(
                    skillsText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
