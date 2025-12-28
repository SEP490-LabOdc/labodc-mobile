import 'package:flutter/material.dart';
import '../../domain/entities/project_entity.dart';
import '../utils/project_data_formatter.dart';
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/service_chip.dart';

class SavedProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final VoidCallback onTap;

  const SavedProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = ProjectDataFormatter.getStatusColor(project.status);

    return ReusableCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  project.projectName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ProjectDataFormatter.translateStatus(project.status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // ID Dự án (projectId)
          const SizedBox(height: 4),
          Text(
            "ID: ${project.projectId}",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),

          const Divider(height: 24),

          // 2. Mô tả (description) - Hiển thị tối đa 2 dòng để card không quá dài
          Text(
            project.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // 3. Thông tin chi tiết (Thời gian & Số lượng ứng viên)
          Row(
            children: [
              _buildInfoItem(
                context,
                Icons.calendar_today_rounded,
                "${ProjectDataFormatter.formatDate(project.startDate)} - ${ProjectDataFormatter.formatDate(project.endDate)}",
              ),
              const Spacer(),
              _buildInfoItem(
                context,
                Icons.group_outlined,
                "${project.currentApplicants} ứng viên",
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Danh sách kỹ năng (Skills) sử dụng ServiceChip của bạn
          if (project.skills.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Chỉ hiển thị tối đa 3 skill tiêu biểu để giữ layout sạch sẽ
                ...project.skills.map((skill) {
                  return ServiceChip(
                    name: skill.name,
                    color: "#000000",
                    small: true,
                  );
                }),
                if (project.skills.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}