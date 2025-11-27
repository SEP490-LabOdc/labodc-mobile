import 'package:flutter/material.dart';
import '../../../hiring_projects/data/models/project_detail_model.dart';

class ApplyConfirmationModal extends StatelessWidget {
  final ProjectDetailModel project;
  final String fileName; // Tên file CV để hiển thị
  final bool isApplying; // Trạng thái loading khi đang gọi API apply
  final VoidCallback onConfirm;

  const ApplyConfirmationModal({
    super.key,
    required this.project,
    required this.fileName,
    required this.isApplying,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Sử dụng Column với mainAxisSize.min để modal chỉ cao vừa đủ nội dung
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.verified_user_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text('Xác nhận ứng tuyển', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),

          // Project Summary Info
          Text('Dự án:', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(project.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // CV Info Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf_rounded, color: Colors.red[400], size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CV sẽ được gửi:', style: theme.textTheme.bodySmall),
                      const SizedBox(height: 4),
                      // Hiển thị tên file từ model
                      Text(fileName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                // Disable nút khi đang loading
                onPressed: isApplying ? null : () => Navigator.pop(context),
                child: const Text('Hủy bỏ'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                // Disable nút và gọi onConfirm khi không loading
                onPressed: isApplying ? null : onConfirm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                // Hiển thị loading indicator nếu đang apply
                icon: isApplying
                    ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label: Text(isApplying ? 'Đang gửi...' : 'Xác nhận & Gửi'),
              ),
            ],
          ),
          const SizedBox(height: 16), // Bottom padding for safety
        ],
      ),
    );
  }
}