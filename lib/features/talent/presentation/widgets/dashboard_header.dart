// lib/features/talent/presentation/widgets/dashboard_header.dart
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final ThemeData theme;

  const DashboardHeader({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Chào buổi sáng,",
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
        ),
        Text(
          "Nguyễn Văn A!", // Tên talent (thường lấy từ Auth/Profile Cubit)
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}