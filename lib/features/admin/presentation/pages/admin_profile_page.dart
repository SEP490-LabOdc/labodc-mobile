// lib/features/admin/presentation/pages/admin_profile_page.dart
import 'package:flutter/material.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_pin_circle, size: 60, color: Colors.indigo),
          SizedBox(height: 16),
          Text(
            "Admin Profile",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text("Quản lý thông tin tài khoản Admin"),
        ],
      ),
    );
  }
}