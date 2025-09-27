import 'package:flutter/material.dart';
import 'package:labodc_mobile/features/company/presentation/pages/payments_page.dart';
import 'package:labodc_mobile/features/company/presentation/pages/project_tracking_page.dart';
import 'package:labodc_mobile/features/company/presentation/pages/reports_page.dart';

import 'company_profile_page.dart';

class CompanyMainPage extends StatefulWidget {
  const CompanyMainPage({super.key});

  @override
  State<CompanyMainPage> createState() => _CompanyMainPageState();
}

class _CompanyMainPageState extends State<CompanyMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ProjectTrackingPage(),
    ReportsPage(),
    PaymentsPage(),
    CompanyProfilePage(),
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
              icon: Icon(Icons.trending_up),
              label: 'Tiến độ'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.description),
              label: 'Báo cáo'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.payment),
              label: 'Thanh toán'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Hồ sơ'
          ),
        ],
      ),
    );
  }
}