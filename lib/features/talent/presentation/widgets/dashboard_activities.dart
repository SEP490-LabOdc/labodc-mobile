// lib/features/talent/presentation/widgets/dashboard_activities.dart
import 'package:flutter/material.dart';
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/activity_item.dart'; // Giả sử ActivityItem tồn tại

class DashboardActivities extends StatelessWidget {
  const DashboardActivities({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hoạt động gần đây",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ReusableCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              ActivityItem(
                icon: Icons.upload_file,
                title: "Đã tải lên file 'design_v2.fig'",
                subtitle: "Dự án 'Ứng dụng di động'",
                time: "10 phút trước",
              ),
              Divider(height: 0),
              ActivityItem(
                icon: Icons.person_add,
                title: "Thêm thành viên mới vào dự án 'Quản lý kho'",
                subtitle: "Dự án 'Ứng dụng di động'",
                time: "1 giờ trước",
              ),
              Divider(height: 0),
              ActivityItem(
                icon: Icons.comment,
                title: "Nhận xét mới trên Task #123",
                subtitle: "Dự án 'Ứng dụng di động'",
                time: "2 giờ trước",
              ),
            ],
          ),
        ),
      ],
    );
  }
}