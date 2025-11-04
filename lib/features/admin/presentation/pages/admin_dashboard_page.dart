// lib/features/admin/presentation/pages/admin_dashboard_page.dart
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor, size: 60, color: Colors.blueGrey),
          SizedBox(height: 16),
          Text(
            "Admin Dashboard",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text("Tổng quan hệ thống và chỉ số chính"),
        ],
      ),
    );
  }
}