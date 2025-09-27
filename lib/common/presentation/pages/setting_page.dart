import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Thêm import GoRouter

import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/theme/bloc/theme_events.dart';
import '../../../core/theme/domain/entity/theme_entity.dart';
import '../../../features/auth/presentation/provider/auth_provider.dart';
import '../../../shared/widgets/reusable_card.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeBloc = context.read<ThemeBloc>();
    final isDark = context.watch<ThemeBloc>().state.themeEntity?.themeType == ThemeType.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          // Theme Switch
          ReusableCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.brightness_6),
                    SizedBox(width: 12),
                    Text("Chế độ tối"),
                  ],
                ),
                CupertinoSwitch(
                  value: isDark,
                  onChanged: (_) {
                    themeBloc.add(ToggleThemeEvent());
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Logout
          ReusableCard(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                // Gọi logout từ authProvider
                authProvider.logout();
                // Hiển thị SnackBar xác nhận
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Đăng xuất thành công!"),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
                // Điều hướng về LoginPage sử dụng GoRouter
                if (!mounted) return;
                context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}