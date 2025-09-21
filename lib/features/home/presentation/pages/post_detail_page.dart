import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PostDetailPage extends StatelessWidget {
  final int id;
  final String title;
  final String body;
  final int userId;

  const PostDetailPage({
    Key? key,
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.softBlack : AppColors.softWhite;
    final cardColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Chi tiết bài viết'),
        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      body: Center(
        child: Card(
          color: cardColor,
          margin: const EdgeInsets.all(24),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: TextStyle(
                    color: textColor.withOpacity(0.85),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(Icons.person, color: isDark ? AppColors.secondary : AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Tác giả: $userId',
                      style: TextStyle(
                        color: isDark ? AppColors.secondary : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      label: Text('ID: $id'),
                      backgroundColor: isDark ? AppColors.darkAccent : AppColors.accent,
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

