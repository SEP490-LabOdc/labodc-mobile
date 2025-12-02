import 'package:flutter/material.dart';
import 'package:labodc_mobile/features/mentor/presentation/pages/mentor_approvals_page.dart';
import 'package:labodc_mobile/features/mentor/presentation/pages/mentor_chat_page.dart';
import '../../../user_profile/presentation/pages/profile_page.dart';
import 'mentor_dashboard_page.dart';


class MentorMainPage extends StatefulWidget {
  const MentorMainPage({super.key});

  @override
  State<MentorMainPage> createState() => _MentorMainPageState();
}

class _MentorMainPageState extends State<MentorMainPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MentorDashboardPage(),
    const MentorApprovalsPage(),
    const MentorChatPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.approval),
            label: "Phê duyệt",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Tin nhắn",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Cá nhân",
          ),
        ],
      ),
    );
  }
}