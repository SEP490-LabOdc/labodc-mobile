import 'package:flutter/material.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';
import '../../data/models/my_application_model.dart';

class ApplicationDetailModal extends StatelessWidget {
  final MyApplicationModel app;

  const ApplicationDetailModal({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    final statusColor = ProjectDataFormatter.getApplicationStatusColor(app.status);
    final statusText = ProjectDataFormatter.translateApplicationStatus(app.status);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh kéo giả định
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Chi tiết đơn ứng tuyển",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          _buildInfoField("Dự án", app.projectName),
          _buildInfoField("Trạng thái", statusText, textColor: statusColor),
          _buildInfoField("Ngày nộp", ProjectDataFormatter.formatDateTime(app.appliedAt)),
          _buildInfoField("Cập nhật cuối", ProjectDataFormatter.formatDateTime(app.updatedAt)),

          // Ô LÝ DO (Hiển thị chuyên nghiệp nếu bị từ chối/hủy)
          if ((app.status == 'REJECTED' || app.status == 'CANCELED') && app.reason != null)
            _buildReasonBox(app.reason!),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Đóng", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text("$label:", style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonBox(String reason) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text("Lý do từ chối", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}