import 'package:flutter/material.dart';

/// Error view widget with retry functionality
class ErrorView extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final Color? iconColor;

  const ErrorView({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor,
  });

  // Predefined error states
  factory ErrorView.network({VoidCallback? onRetry}) {
    return ErrorView(
      icon: Icons.wifi_off,
      title: 'Không có kết nối mạng',
      message: 'Vui lòng kiểm tra kết nối internet và thử lại.',
      onRetry: onRetry,
      iconColor: Colors.orange,
    );
  }

  factory ErrorView.serverError({VoidCallback? onRetry}) {
    return ErrorView(
      icon: Icons.cloud_off,
      title: 'Lỗi máy chủ',
      message: 'Đã xảy ra lỗi khi kết nối với máy chủ. Vui lòng thử lại sau.',
      onRetry: onRetry,
      iconColor: Colors.red,
    );
  }

  factory ErrorView.unauthorized({VoidCallback? onLogin}) {
    return ErrorView(
      icon: Icons.lock_outline,
      title: 'Phiên đăng nhập hết hạn',
      message: 'Vui lòng đăng nhập lại để tiếp tục.',
      onRetry: onLogin,
      iconColor: Colors.amber,
    );
  }

  factory ErrorView.notFound() {
    return const ErrorView(
      icon: Icons.search_off,
      title: 'Không tìm thấy',
      message: 'Nội dung bạn tìm kiếm không tồn tại hoặc đã bị xóa.',
      iconColor: Colors.grey,
    );
  }

  factory ErrorView.generic({String? message, VoidCallback? onRetry}) {
    return ErrorView(
      icon: Icons.error_outline,
      title: 'Đã xảy ra lỗi',
      message:
          message ?? 'Một lỗi không mong muốn đã xảy ra. Vui lòng thử lại.',
      onRetry: onRetry,
      iconColor: Colors.red,
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
            // Error icon with pulse animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.red).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 64, color: iconColor ?? Colors.red),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),

            // Retry button (optional)
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  backgroundColor: iconColor ?? theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error snackbar helper
class ErrorSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Thử lại',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}
