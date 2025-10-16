// lib/features/talent/presentation/widgets/dashboard_quick_actions.dart
import 'package:flutter/material.dart';
import '../../../../shared/widgets/reusable_card.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
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
          "Thao tác nhanh",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ReusableCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(context, Icons.add_box, "Tạo hoá đơn", () {}),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              _buildActionButton(context, Icons.calendar_today, "Lịch làm việc", () {}),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              _buildActionButton(context, Icons.history, "Xem giao dịch", () {}),
            ],
          ),
        ),
      ],
    );
  }
}