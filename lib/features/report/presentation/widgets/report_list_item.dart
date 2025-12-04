import 'package:flutter/material.dart';
import '../../../../shared/widgets/network_image_with_fallback.dart';
import '../../data/model/report_model.dart';

class ReportListItem extends StatelessWidget {
  final ReportItemModel report;

  const ReportListItem({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkImageWithFallback(
              imageUrl: report.reporterAvatar ?? "",
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(50),
              fallbackIcon: Icons.person,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.projectName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    "Người gửi: ${report.reporterName}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    report.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Ngày gửi: ${report.reportingDate.toString().split(' ').first}",
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
