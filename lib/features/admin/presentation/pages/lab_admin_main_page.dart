// lib/features/admin/presentation/pages/lab_admin_main_page.dart (Phiên bản đã sửa)

import 'package:flutter/material.dart';
import 'admin_dashboard_page.dart';
import 'admin_profile_page.dart';


class LabAdminMainPage extends StatefulWidget {
  const LabAdminMainPage({super.key});

  @override
  State<LabAdminMainPage> createState() => _LabAdminMainPageState();
}

class _LabAdminMainPageState extends State<LabAdminMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminDashboardPage(),
    AdminProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Hồ sơ'
          ),
        ],
      ),
    );
  }
}