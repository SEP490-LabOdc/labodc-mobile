// features/talent/presentation/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:labodc_mobile/core/theme/app_colors.dart';

import '../../../../shared/widgets/project_card.dart';
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/activity_item.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int unreadNotifications = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text("Talent Dashboard"),
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
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 400),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 30,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  _buildWelcomeSection(theme),
                  const SizedBox(height: 20),
                  _buildStatisticsSection(),
                  const SizedBox(height: 24),
                  _buildProjectsSection(),
                  const SizedBox(height: 24),
                  _buildTasksSection(),
                  const SizedBox(height: 24),
                  _buildActivitiesSection(),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return ReusableCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withOpacity(0.85),
          theme.colorScheme.primary,
        ],
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
    return const SectionCard(
      title: "📊 Tổng quan",
      child: Column(
        children: [
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
              SizedBox(width: 12),
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
        ],
      ),
    );
  }

  Widget _buildProjectsSection() {
    return SectionCard(
      title: "🚀 Dự án đang tham gia",
      actions: [TextButton(onPressed: () {}, child: const Text("Xem tất cả"))],
      child: Column(
        children: [
          ProjectCard(
            projectName: "E-commerce Platform",
            companyName: "ABC Corp",
            progress: 0.75,
            role: "Frontend Developer",
            deadline: "5 ngày",
            status: "active",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    return SectionCard(
      title: "📌 Task hôm nay",
      child: Column(
        children: [
          TaskCard(
            title: "[URGENT] Fix login bug on iOS",
            description: "high",
            dueTime: "2 giờ",
            // isCompleted: false,
            color: AppColors.accent,
            // onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return SectionCard(
      title: "📝 Hoạt động gần đây",
      child: Column(
        children: const [
          ActivityItem(
            icon: Icons.check_circle,
            subtitle: "...",
            color: Colors.green,
            title: "Task 'Login UI' đã được duyệt",
            time: "5 phút trước",
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return SectionCard(
      title: "⚡ Thao tác nhanh",
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          QuickActionCard(
            icon: Icons.chat_bubble_outline,
            title: "Tin nhắn",
            subtitle: "3 tin mới",
            color: Colors.blue,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ==== NOTIFICATION BOTTOM SHEET ====
  void _showNotificationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => const Center(child: Text("Thông báo")),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }
}
