// lib/features/talent/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

// 🔥 PHẦN MỚI: Import NotificationBell
import '../../../../core/router/route_constants.dart';
import '../../../notification/presentation/widgets/notification_bell.dart';

// Import các widget con đã tách
import '../../../project_application/presentation/widgets/my_projects_section.dart';
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

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
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
            const NotificationBell(iconSize: 24),
            const SizedBox(width: 8),
          ]
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
                  DashboardHeader(theme: theme),
                  const SizedBox(height: 20),
                  const DashboardStatistics(),
                  const SizedBox(height: 24),
                  MyProjectsSection(
                    title: "Dự án của tôi",
                  ),
                  // const DashboardProjects(),
                  const SizedBox(height: 24),
                  const DashboardTasks(),
                  const SizedBox(height: 24),
                  const DashboardActivities(),
                  const SizedBox(height: 24),
                  const DashboardQuickActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}