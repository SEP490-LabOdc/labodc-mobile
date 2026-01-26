import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/notification_entity.dart';
import '../../websocket/cubit/websocket_notification_cubit.dart';
import '../../../auth/presentation/provider/auth_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // [Safety Net] Buộc fetch lại dữ liệu khi vào trang này để đảm bảo đồng bộ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final user = auth.currentUser;
      final token = auth.accessToken;

      if (user != null && token != null) {
        // connect() sẽ tự động fetch API trước, sau đó nối socket
        context.read<WebSocketNotificationCubit>().connect(user.userId, token);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

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
    final Color primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.primary;
    final Color textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Thông báo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: textColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          labelColor: textColor,
          unselectedLabelColor: textColor.withOpacity(0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Tất cả"),
            Tab(text: "Chưa đọc"),
          ],
        ),
      ),
      body: BlocBuilder<WebSocketNotificationCubit, List<NotificationEntity>>(
        builder: (context, list) {
          final unreadList = list.where((n) => !n.readStatus).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationList(
                context,
                list,
                emptyMessage: "Bạn chưa có thông báo nào",
              ),
              _buildNotificationList(
                context,
                unreadList,
                emptyMessage: "Không có thông báo chưa đọc",
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(
    BuildContext context,
    List<NotificationEntity> items, {
    required String emptyMessage,
  }) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = items[index];
        final isRead = notification.readStatus;

        return Dismissible(
          key: ValueKey(notification.notificationRecipientId),
          direction: DismissDirection.startToEnd, // Swipe RIGHT to delete
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: const [
                Icon(Icons.delete, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text(
                  'Xóa',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            // Show confirmation dialog
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Xóa thông báo?'),
                content: const Text(
                  'Bạn có chắc muốn xóa thông báo này không?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Xóa',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) async {
            final auth = context.read<AuthProvider>();
            final cubit = context.read<WebSocketNotificationCubit>();

            try {
              await cubit.deleteNotification(
                notification.notificationRecipientId,
                token: auth.accessToken,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa thông báo'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          },
          child: InkWell(
            onTap: () {
              // 1. Logic Optimistic Update: Gọi Cubit để mark read + update UI ngay
              if (!isRead) {
                context.read<WebSocketNotificationCubit>().markAsRead(
                  notification.notificationRecipientId,
                );
              }

              // 2. Logic Navigation (nếu có deepLink)
              // if (notification.deepLink != null) { ... }
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Logic màu nền: Chưa đọc -> Có màu nền nhẹ / Đã đọc -> Trong suốt
                color: isRead
                    ? theme.colorScheme.surface
                    : theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isRead
                      ? theme.dividerColor.withOpacity(0.1)
                      : theme.colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: isRead
                    ? []
                    : [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon hoặc Avatar thông báo
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isRead
                          ? theme.colorScheme.surfaceVariant
                          : theme.colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      // Icon thay đổi tùy theo category (có thể customize thêm)
                      _getIconForCategory(notification.category),
                      size: 20,
                      color: isRead
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Nội dung chính
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isRead
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                  color: isRead
                                      ? theme.colorScheme.onSurface.withOpacity(
                                          0.8,
                                        )
                                      : theme.colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Dấu chấm xanh chỉ hiện khi chưa đọc
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.content,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: theme.colorScheme.onSurface.withOpacity(
                              isRead ? 0.6 : 0.8,
                            ),
                            fontWeight: isRead
                                ? FontWeight.normal
                                : FontWeight.w500,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatTime(notification.sentAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.outline,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper để chọn icon (Optional)
  IconData _getIconForCategory(String? category) {
    final key = (category ?? '').toUpperCase();
    switch (key) {
      case 'SYSTEM':
        return Icons.settings_suggest_rounded;
      case 'PROJECT':
        return Icons.work_outline_rounded;
      case 'MESSAGE':
        return Icons.chat_bubble_outline_rounded;
      case 'ALERT':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }
}
