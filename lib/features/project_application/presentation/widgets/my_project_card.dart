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

    // Sử dụng Formatter
    final statusColor = ProjectDataFormatter.getStatusColor(status);
    final statusText = ProjectDataFormatter.translateStatus(status);
    final formattedBudget = ProjectDataFormatter.formatCurrency(context, budget);
    final dateRange = _formatDateRange();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
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
                          // 🔥 HERO ANIMATION cho Title
                          Hero(
                            tag: 'project_title_$projectId',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                projectName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
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
                                Icon(Icons.business, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    companyName!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
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
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
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

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, thickness: 0.5),
                ),

                // --- BODY: DESCRIPTION ---
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
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
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.monetization_on_outlined, size: 16, color: Colors.green.shade700),
                          const SizedBox(width: 6),
                          Text(
                            formattedBudget,
                            style: TextStyle(
                              color: Colors.green.shade700,
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
                          Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            dateRange,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
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
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          name,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
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