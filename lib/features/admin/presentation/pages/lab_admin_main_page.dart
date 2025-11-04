// lib/features/admin/presentation/pages/lab_admin_main_page.dart (Phiên bản đã sửa)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// ... (Các imports khác)
import '../../../../core/router/route_constants.dart';
import 'admin_dashboard_page.dart';
import 'admin_profile_page.dart';
import '../../../notification/presentation/cubit/notification_cubit.dart';
import '../../../notification/presentation/cubit/notification_state.dart'; //

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

  // ✅ CHUYÊN NGHIỆP: Loại bỏ initState, didChangeDependencies và _handleFCM...
  // Widget không còn quản lý vòng đời của Stream Subscription.

  // --- HÀM XỬ LÝ SIDE EFFECT DỰA TRÊN STATE CỦA CUBIT ---
  void _listener(BuildContext context, NotificationState state) {
    state.whenOrNull(
      newMessageReceived: (message) {
        // State được Cubit emit khi nhận FCM Foreground
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔔 Thông báo mới: ${message['notification']['title']}'),
            backgroundColor: Colors.blueAccent,
          ),
        );
      },
      navigateTo: (route) {
        // State được Cubit emit khi FcmService.onMessageOpenedApp được gọi
        context.go(route);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // ✅ CHUYÊN NGHIỆP: Truy cập Cubit bằng Provider.of hoặc context.read()
    final notificationCubit = context.read<NotificationCubit>();

    return BlocListener<NotificationCubit, NotificationState>(
      listener: _listener,
      // listenWhen: (previous, current) => current is NewMessageReceived || current is NavigateTo, // Tùy chọn để tối ưu
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lab Admin Main'),
          actions: [
            // Hiển thị trạng thái thông báo
            BlocBuilder<NotificationCubit, NotificationState>(
              bloc: notificationCubit,
              builder: (context, state) {
                final unreadCount = state.maybeWhen(
                  loaded: (list) => list.where((n) => !n.isRead).length,
                  orElse: () => 0,
                );

                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {
                        // Điều hướng đến trang thông báo
                        context.go('${Routes.labAdmin}/notifications');
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 11,
                        top: 11,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // ... Logic Logout
              },
            ),
          ],
        ),

        body: _pages[_currentIndex],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
          ],
        ),
      ),
    );
  }
}