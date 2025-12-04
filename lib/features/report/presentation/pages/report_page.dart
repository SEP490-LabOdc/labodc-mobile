import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/report_cubit.dart';
import '../widgets/report_list_widget.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late TabController tab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.primary;
    final Color textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: const Text(
            "Báo cáo",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          bottom: TabBar(
            indicator: BoxDecoration(
              color: textColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorAnimation: TabIndicatorAnimation.elastic,
            indicatorPadding: const EdgeInsets.symmetric(
              horizontal: -60,
              vertical: -3,
            ),
            labelColor: textColor,
            unselectedLabelColor: textColor,
            indicatorColor: primaryColor,
            tabs: const [
              Tab(text: "Đã gửi"),
              Tab(text: "Đã nhận"),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            BlocProvider(
              create: (_) => getIt<ReportCubit>(param1: true)..loadReports(),
              child: const ReportListWidget(),
            ),

            BlocProvider(
              create: (_) => getIt<ReportCubit>(param1: false)..loadReports(),
              child: const ReportListWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
