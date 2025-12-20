import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/features/project_fund/presentation/pages/project_fund_page.dart';
import 'package:labodc_mobile/features/talent/presentation/pages/talent_report_page.dart';
import 'package:labodc_mobile/features/user_profile/presentation/pages/profile_page.dart';
import 'package:labodc_mobile/wallet/presentation/pages/my_wallet_page.dart';
// import 'package:labodc_mobile/features/talent/presentation/pages/tasks_page.dart'; // Uncomment nếu dùng

import '../../../notification/domain/entities/notification_entity.dart';
import '../../../notification/websocket/cubit/websocket_notification_cubit.dart';
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
    ProjectFundPage(),
    MyWalletPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Bọc Scaffold trong BlocListener để lắng nghe thông báo toàn cục ở trang này
    return BlocListener<WebSocketNotificationCubit, List<NotificationEntity>>(
      listenWhen: (previous, current) {
        // [QUAN TRỌNG] Logic chặn lỗi hiển thị sai:
        // Chỉ hiện popup khi Số lượng tin nhắn TĂNG LÊN (có tin mới).
        // Khi đánh dấu đã đọc (markAsRead), số lượng giữ nguyên -> Trả về false.

        return current.length > previous.length;
      },
      listener: (context, state) {
        // Chỉ chạy khi listenWhen trả về true
        if (state.isEmpty) return;

        final newNotif = state.first;

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            content: Row(
              children: [
                Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.onInverseSurface, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          newNotif.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                      ),
                      Text(
                          newNotif.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                      ),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Khám phá'),
            // BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Nhiệm vụ'),
            BottomNavigationBarItem(icon: Icon(Icons.wallet_membership), label: 'Quỹ'),
            BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Ví'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
          ],
        ),
      ),
    );
  }
}