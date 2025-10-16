// lib/features/talent/presentation/widgets/dashboard_tasks.dart
import 'package:flutter/material.dart';
import '../../../../shared/widgets/reusable_card.dart'; // Giả sử ReusableCard tồn tại

class DashboardTasks extends StatelessWidget {
  const DashboardTasks({super.key});

  Widget _buildTaskItem(String title, String deadline, bool isCompleted) {
    return ListTile(
      leading: Icon(
        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isCompleted ? Colors.green : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: Text(deadline),
      onTap: () {
        // Logic chuyển đổi trạng thái Task
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nhiệm vụ trong tuần",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ReusableCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildTaskItem("Hoàn thành module đăng nhập", "Hôm nay", false),
              const Divider(height: 0),
              _buildTaskItem("Gửi báo cáo tiến độ tuần", "Thứ Sáu", false),
              const Divider(height: 0),
              _buildTaskItem("Review code với khách hàng", "Thứ Hai", true),
            ],
          ),
        ),
      ],
    );
  }
}