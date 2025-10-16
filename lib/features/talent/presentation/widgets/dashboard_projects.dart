// lib/features/talent/presentation/widgets/dashboard_projects.dart

import 'package:flutter/material.dart';
import '../../../../shared/widgets/project_card.dart'; // Giả sử ProjectCard tồn tại

class DashboardProjects extends StatelessWidget {
  const DashboardProjects({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Dự án gần đây",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("Xem tất cả"),
            ),
          ],
        ),
        const SizedBox(height: 12),

        const ProjectCard(
          projectName: "Thiết kế Website E-commerce",
          companyName: "TechCorp Solutions",
          role: "UX/UI Designer",
          deadline: "30/11/2025",
          status: "Đang tiến hành",
          progress: 0.75,
        ),

        const ProjectCard(
          projectName: "Xây dựng Backend cho Ứng dụng Quản lý",
          companyName: "FinTech Innovation",
          role: "Flutter Developer",
          deadline: "15/12/2025", 
          status: "Cần phản hồi",
          progress: 0.90,
        ),
      ],
    );
  }
}