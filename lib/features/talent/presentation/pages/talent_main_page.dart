import 'package:flutter/material.dart';
import 'package:labodc_mobile/features/talent/presentation/pages/talent_report_page.dart';
import 'package:labodc_mobile/features/user_profile/presentation/pages/profile_page.dart';
import 'package:labodc_mobile/features/talent/presentation/pages/tasks_page.dart';

import '../../../report/presentation/pages/report_page.dart';
import 'dashboard_page.dart';
import 'explore_page.dart';


class TalentMainPage extends StatefulWidget {
  const TalentMainPage({super.key});

  @override
  State<TalentMainPage> createState() => _TalentMainPageState();
}

class _TalentMainPageState extends State<TalentMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    ExplorePage(),
    // TasksPage(),
    ReportPage(),
    ProfilePage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Khám phá'),
          // BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Nhiệm vụ'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Báo cáo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
