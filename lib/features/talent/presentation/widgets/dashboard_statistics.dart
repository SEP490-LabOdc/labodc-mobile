// lib/features/talent/presentation/widgets/dashboard_statistics.dart
import 'package:flutter/material.dart';
import '../../../../shared/widgets/reusable_card.dart'; // Giả sử ReusableCard tồn tại

class DashboardStatistics extends StatelessWidget {
  const DashboardStatistics({super.key});

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon, Color color) {
    return Expanded(
      child: ReusableCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tổng quan",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatItem(context, "3", "Dự án đang làm", Icons.work, Colors.blue),
            const SizedBox(width: 12),
            _buildStatItem(context, "120M", "Thu nhập tháng", Icons.monetization_on, Colors.green),
            const SizedBox(width: 12),
            _buildStatItem(context, "4.8", "Đánh giá", Icons.star, Colors.orange),
          ],
        ),
      ],
    );
  }
}