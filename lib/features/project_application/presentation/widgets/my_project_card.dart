import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';
import '../../../project_application/data/models/my_project_model.dart';

class MyProjectCard extends StatelessWidget {
  final String projectId;
  final String projectName;
  final String description;
  final String status;
  final String? companyName;
  final double? budget;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<dynamic> skills;

  const MyProjectCard({
    super.key,
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

  factory MyProjectCard.fromModel(MyProjectModel model) {
    return MyProjectCard(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Sử dụng Formatter
    final statusColor = ProjectDataFormatter.getStatusColor(status);
    final statusText = ProjectDataFormatter.translateStatus(status);
    final formattedBudget = ProjectDataFormatter.formatCurrency(context, budget);
    final dateRange = _formatDateRange();

    return Container(
      decoration: BoxDecoration(
        // Sử dụng color của Card hoặc surface
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        // Border tinh tế thay đổi theo theme
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            AppRouter.pushNamed(
              Routes.myProjectDetailName,
              pathParameters: {'id': projectId},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: TITLE & STATUS ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'project_title_$projectId',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                projectName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (companyName != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.business, size: 14, color: theme.hintColor),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    companyName!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.hintColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, thickness: 0.5, color: theme.dividerColor.withOpacity(0.2)),
                ),

                // --- BODY: DESCRIPTION ---
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: colorScheme.onSurface.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ),

                // --- FOOTER: METRICS (Budget, Date) ---
                Row(
                  children: [
                    // Budget
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        // Màu xanh lá thích ứng nhẹ với Dark Mode
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on_outlined, size: 16, color: Colors.green),
                          const SizedBox(width: 6),
                          Text(
                            formattedBudget,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Date
                    if (dateRange != null)
                      Row(
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 14, color: theme.hintColor),
                          const SizedBox(width: 4),
                          Text(
                            dateRange,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // --- SKILLS ---
                if (skills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: skills.map((s) {
                      final name = s is Map ? s['name'] : (s.name ?? '');
                      if (name == null) return const SizedBox.shrink();

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                        ),
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _formatDateRange() {
    if (startDate == null) return null;
    final start = ProjectDataFormatter.formatDate(startDate!);
    if (endDate == null) return start;
    final end = ProjectDataFormatter.formatDate(endDate!);
    return "$start - $end";
  }
}