import 'package:flutter/material.dart';
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/service_chip.dart';
import '../../../../shared/widgets/expandable_text.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_constants.dart';
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
        AppRouter.pushNamed(
          Routes.projectDetailName,
          pathParameters: {'id': projectId},
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title + status pill
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

          // company
          Text(
            company,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),

          // description
          ExpandableText(
            text: description,
            maxLines: 3,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),

          // skills
          if (skills.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills.take(8).map((s) {
                final String name = s.name as String;
                final hex = _colorHexFromString(name);
                return ServiceChip(name: name, color: hex, small: true);
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],

          // date
          Text(
            'Từ $start đến $end',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),

          if (budget != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.account_balance_wallet,
                    size: 16, color: theme.colorScheme.primary),
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
