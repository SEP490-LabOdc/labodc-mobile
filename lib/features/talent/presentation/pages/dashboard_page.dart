// features/talent/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';

import '../../../../shared/widgets/reusable_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int unreadNotifications = 5; // Mock data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Talent Dashboard"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Notification Bell
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
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      unreadNotifications > 99 ? '99+' : unreadNotifications.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),

              const SizedBox(height: 20),

              // Statistics Cards
              _buildStatisticsSection(),

              const SizedBox(height: 24),

              // Current Projects
              _buildCurrentProjectsSection(),

              const SizedBox(height: 24),

              // Today's Tasks
              _buildTodayTasksSection(),

              const SizedBox(height: 24),

              // Recent Activities
              _buildRecentActivitiesSection(),

              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return ReusableCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [Colors.blue.shade400, Colors.blue.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wb_sunny, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                "Chào buổi sáng, Talent! 👋",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Hôm nay bạn có 3 task cần hoàn thành",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📊 Tổng quan",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "Dự án tham gia",
                value: "8",
                subtitle: "Tổng cộng",
                icon: Icons.folder_outlined,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: "Đang hoạt động",
                value: "3",
                subtitle: "Dự án",
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "Task hoàn thành",
                value: "42",
                subtitle: "Tháng này",
                icon: Icons.check_circle_outline,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: "Đánh giá trung bình",
                value: "4.8",
                subtitle: "⭐ Sao",
                icon: Icons.star_outline,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentProjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "🚀 Dự án đang tham gia",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all projects
              },
              child: const Text("Xem tất cả"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return ProjectCard(
              projectName: "Dự án ${['E-commerce Platform', 'Mobile Banking App', 'AI Chatbot'][index]}",
              companyName: "Công ty ${['ABC Corp', 'XYZ Tech', 'Innovation Hub'][index]}",
              progress: [0.75, 0.45, 0.90][index],
              role: "Frontend Developer",
              deadline: "${[5, 12, 2][index]} ngày",
              status: ['active', 'active', 'review'][index],
              onTap: () => _openProject(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTodayTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📌 Task hôm nay",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return TaskCard(
              title: [
                "[URGENT] Fix login bug on iOS",
                "[UI] Design product detail page",
                "[API] Integrate payment gateway"
              ][index],
              project: ["E-commerce Platform", "Mobile Banking", "AI Chatbot"][index],
              priority: ["high", "medium", "low"][index],
              dueTime: ["2 giờ", "1 ngày", "3 ngày"][index],
              isCompleted: index == 2,
              onChanged: (value) => _toggleTask(index, value),
              onTap: () => _openTask(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📝 Hoạt động gần đây",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ReusableCard(
          backgroundColor: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade200),
          padding: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              return _ActivityItem(
                icon: [
                  Icons.check_circle,
                  Icons.message,
                  Icons.assignment,
                  Icons.payment,
                  Icons.star
                ][index],
                iconColor: [
                  Colors.green,
                  Colors.blue,
                  Colors.orange,
                  Colors.purple,
                  Colors.amber
                ][index],
                title: [
                  "Task 'Login UI' đã được duyệt",
                  "Tin nhắn mới từ Mentor John",
                  "Task mới được giao: 'Setup Database'",
                  "Thanh toán 5.000.000 VNĐ đã được xử lý",
                  "Nhận đánh giá 5⭐ cho task hoàn thành"
                ][index],
                time: "${[5, 15, 30, 60, 120][index]} phút trước",
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "⚡ Thao tác nhanh",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            QuickActionCard(
              icon: Icons.chat_bubble_outline,
              title: "Tin nhắn",
              subtitle: "5 tin mới",
              color: Colors.blue,
              onTap: () => _openMessages(),
            ),
            QuickActionCard(
              icon: Icons.schedule,
              title: "Timesheet",
              subtitle: "Ghi thời gian",
              color: Colors.green,
              onTap: () => _openTimesheet(),
            ),
            QuickActionCard(
              icon: Icons.account_balance_wallet,
              title: "Thu nhập",
              subtitle: "12.500.000 VNĐ",
              color: Colors.orange,
              onTap: () => _openEarnings(),
            ),
            QuickActionCard(
              icon: Icons.support_agent,
              title: "Hỗ trợ",
              subtitle: "Liên hệ mentor",
              color: Colors.purple,
              onTap: () => _openSupport(),
            ),
          ],
        ),
      ],
    );
  }

  void _showNotificationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Thông báo",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        unreadNotifications = 0;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("Đánh dấu đã đọc"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    final isUnread = index < unreadNotifications;
                    return ReusableCard(
                      margin: const EdgeInsets.only(bottom: 8),
                      backgroundColor: isUnread ? Colors.blue.shade50 : Colors.transparent,
                      border: Border.all(
                        color: isUnread ? Colors.blue.shade200 : Colors.grey.shade200,
                      ),
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: [
                            Colors.green, Colors.blue, Colors.orange,
                            Colors.red, Colors.purple, Colors.teal,
                            Colors.amber, Colors.pink
                          ][index],
                          child: Icon(
                            [
                              Icons.check_circle, Icons.message, Icons.assignment,
                              Icons.warning, Icons.payment, Icons.star,
                              Icons.person_add, Icons.celebration
                            ][index],
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        title: Text([
                          "Task 'API Integration' đã được duyệt",
                          "Tin nhắn mới từ Mentor Sarah",
                          "Bạn có task mới: 'Database Setup'",
                          "Task 'Login Fix' sắp hết hạn",
                          "Thanh toán tuần đã được xử lý",
                          "Đánh giá mới: 5⭐ cho công việc tuyệt vời",
                          "Mentor mới được thêm vào dự án",
                          "Chúc mừng! Bạn đã hoàn thành milestone"
                        ][index]),
                        subtitle: Text("${[10, 25, 45, 60, 90, 120, 180, 240][index]} phút trước"),
                        trailing: isUnread
                            ? Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Refresh data here
    });
  }

  void _openProject(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đang mở dự án $index...")),
    );
  }

  void _toggleTask(int index, bool? value) {
    setState(() {
      // Update task completion status
    });
  }

  void _openTask(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đang mở task $index...")),
    );
  }

  void _openMessages() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đang mở tin nhắn...")),
    );
  }

  void _openTimesheet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đang mở timesheet...")),
    );
  }

  void _openEarnings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đang mở thông tin thu nhập...")),
    );
  }

  void _openSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đang kết nối với hỗ trợ...")),
    );
  }
}

// === CUSTOM WIDGETS ===

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(time, style: const TextStyle(fontSize: 12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}