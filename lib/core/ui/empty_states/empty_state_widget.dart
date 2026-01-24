import 'package:flutter/material.dart';

/// Empty state widget with customizable icon, message, and action
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
    this.iconColor,
  });

  // Predefined empty states
  factory EmptyStateWidget.noSavedProjects({VoidCallback? onBrowse}) {
    return EmptyStateWidget(
      icon: Icons.bookmark_border,
      title: 'Chưa có dự án đã lưu',
      message: 'Các dự án bạn lưu sẽ hiển thị ở đây để bạn dễ dàng truy cập.',
      actionLabel: onBrowse != null ? 'Khám phá dự án' : null,
      onActionPressed: onBrowse,
      iconColor: Colors.blue,
    );
  }

  factory EmptyStateWidget.noNotifications() {
    return const EmptyStateWidget(
      icon: Icons.notifications_none,
      title: 'Chưa có thông báo',
      message: 'Bạn sẽ nhận được thông báo về các hoạt động quan trọng ở đây.',
      iconColor: Colors.orange,
    );
  }

  factory EmptyStateWidget.noSearchResults({VoidCallback? onClearSearch}) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Không tìm thấy kết quả',
      message: 'Thử tìm kiếm với từ khóa khác hoặc điều chỉnh bộ lọc.',
      actionLabel: onClearSearch != null ? 'Xóa bộ lọc' : null,
      onActionPressed: onClearSearch,
      iconColor: Colors.grey,
    );
  }

  factory EmptyStateWidget.noApplications({VoidCallback? onBrowse}) {
    return EmptyStateWidget(
      icon: Icons.work_outline,
      title: 'Chưa có ứng tuyển',
      message: 'Các dự án bạn ứng tuyển sẽ được hiển thị ở đây.',
      actionLabel: onBrowse != null ? 'Tìm dự án' : null,
      onActionPressed: onBrowse,
      iconColor: Colors.green,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with background
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (iconColor ?? theme.primaryColor).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? theme.primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),

            // Action button (optional)
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.arrow_forward),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
