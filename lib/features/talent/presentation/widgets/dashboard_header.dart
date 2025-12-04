// lib/features/talent/presentation/widgets/dashboard_header.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/provider/auth_provider.dart';

class DashboardHeader extends StatelessWidget {
  final ThemeData theme;

  const DashboardHeader({super.key, required this.theme});

  /// Hàm xác định câu chào theo giờ hiện tại
  String _getGreetingByTime() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Chào buổi sáng,";
    } else if (hour >= 12 && hour < 14) {
      return "Chào buổi trưa,";
    } else if (hour >= 14 && hour < 18) {
      return "Chào buổi chiều,";
    } else if (hour >= 18 && hour < 23) {
      return "Chào buổi tối,";
    } else {
      return "Chào bạn,";
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.fullName ?? "bạn";

    final greeting = _getGreetingByTime();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          "$userName!",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
