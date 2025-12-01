import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/domain/entity/theme_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../websocket/cubit/websocket_notification_cubit.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController tab;

  @override
  void initState() {
    super.initState();
    tab = TabController(length: 2, vsync: this);
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return "Vừa xong";
    if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
    if (diff.inHours < 24) return "${diff.inHours} giờ trước";
    if (diff.inDays == 1) return "Hôm qua";

    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final Color textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;


    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Thông báo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: tab,
          indicator: BoxDecoration(
            color: textColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorAnimation: TabIndicatorAnimation.elastic,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: -60, vertical: -3),
          labelColor: textColor,
          unselectedLabelColor: textColor,
          indicatorColor: primaryColor,

          tabs: const [
            Tab(text: "Tất cả"),
            Tab(text: "Chưa đọc"),
          ],
        ),
      ),
      body: BlocBuilder<WebSocketNotificationCubit, List<NotificationEntity>>(
        builder: (context, list) {
          final unread = list.where((n) => !n.readStatus).toList();
          return TabBarView(
            controller: tab,
            children: [
              _buildList(context, list),
              _buildList(context, unread),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<NotificationEntity> items) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 70, color: theme.colorScheme.onSurface.withOpacity(0.4)),
            const SizedBox(height: 14),
            Text(
              "Không có thông báo",
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
      const SizedBox(height: 10), // spacing đẹp hơn và thoáng hơn
      itemBuilder: (context, index) {
        final n = items[index];

        return Dismissible(
          key: ValueKey(n.notificationRecipientId),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.check_circle, color: Colors.white, size: 28),
          ),
          onDismissed: (_) {
            context
                .read<WebSocketNotificationCubit>()
                .markAsRead(n.notificationRecipientId);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: n.readStatus
                  ? theme.colorScheme.surfaceVariant.withOpacity(0.4)
                  : theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: n.readStatus
                    ? Colors.transparent
                    : theme.colorScheme.primary.withOpacity(0.4),
                width: 1.1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left indicator dot
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: n.readStatus
                        ? Colors.transparent
                        : theme.colorScheme.primary,
                  ),
                ),

                // Content
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: n.readStatus
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          n.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatTime(n.sentAt),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
