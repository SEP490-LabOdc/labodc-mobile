// features/talent/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// Import các widget con đã tách
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_statistics.dart';
import '../widgets/dashboard_projects.dart';
import '../widgets/dashboard_tasks.dart';
import '../widgets/dashboard_activities.dart';
import '../widgets/dashboard_quick_actions.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ✅ (Tạm thời) Giữ biến local, sau này thay bằng Cubit/Bloc
  int unreadNotifications = 3;

  Future<void> _refreshData() async {
    // Logic tải lại dữ liệu từ server ở đây (Ví dụ: fetch projects, fetch tasks...)
    await Future.delayed(const Duration(seconds: 1));
    if(mounted) {
      setState(() {
        // Ví dụ: giảm số thông báo chưa đọc sau khi refresh
        unreadNotifications = 0;
      });
    }
  }

  void _showNotificationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Thông báo",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: EdgeInsets.zero,
                      children: const [
                        ListTile(title: Text("Dự án mới: UX/UI cho ứng dụng Mobile"), subtitle: Text("2 giờ trước")),
                        ListTile(title: Text("Thanh toán thành công"), subtitle: Text("1 ngày trước")),
                        ListTile(title: Text("Cảnh báo: Hạn chót dự án A sắp đến"), subtitle: Text("12 giờ trước")),
                        ListTile(title: Text("Cảnh báo: Hạn chót dự án A sắp đến"), subtitle: Text("1 ngày trước")),
                        ListTile(title: Text("Cảnh báo: Hạn chót dự án A sắp đến"), subtitle: Text("2 ngày trước")),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // Sau khi đóng bottom sheet, cập nhật số thông báo (tạm thời)
      setState(() {
        unreadNotifications = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text(
            "Talent Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => _showNotificationBottomSheet(context),
              ),
              if (unreadNotifications > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadNotifications.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // ✅ ĐÃ SỬA: Dùng AnimationConfiguration.toStaggeredList
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 400),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 30,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  DashboardHeader(theme: theme), // ✅ Widget đã tách
                  const SizedBox(height: 20),
                  const DashboardStatistics(), // ✅ Widget đã tách
                  const SizedBox(height: 24),
                  const DashboardProjects(), // ✅ Widget đã tách
                  const SizedBox(height: 24),
                  const DashboardTasks(), // ✅ Widget đã tách
                  const SizedBox(height: 24),
                  const DashboardActivities(), // ✅ Widget đã tách
                  const SizedBox(height: 24),
                  const DashboardQuickActions(), // ✅ Widget đã tách
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}