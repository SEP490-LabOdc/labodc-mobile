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
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Drag Handle (Thanh kéo đặc trưng của BottomSheet)
          Center(
            child: Container(
              width: 48,
              height: 5,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),

          // 2. Header Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.rocket_launch_outlined, color: theme.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xác nhận ứng tuyển',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kiểm tra lại thông tin trước khi gửi',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(height: 1, thickness: 0.5),
          ),

          // 3. Project Info Section
          Text(
            'Dự án đang ứng tuyển',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            project.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 24),

          // 4. CV File Card Section
          Text(
            'Hồ sơ đính kèm (CV)',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // File Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.picture_as_pdf_rounded, color: Colors.red.shade400, size: 28),
                ),
                const SizedBox(width: 16),

                // File Name & Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: Colors.green.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Sẵn sàng để gửi',
                            style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 5. Action Buttons (Full width)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: isApplying ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: Colors.grey.shade700,
                    ),
                    child: const Text('Hủy bỏ', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2, // Nút confirm to hơn
                child: SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: isApplying ? null : onConfirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    icon: isApplying
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                    )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      isApplying ? 'Đang gửi...' : 'Xác nhận & Gửi',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}