import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/bloc/theme_bloc.dart';
import '../../../core/theme/bloc/theme_events.dart';
import '../../../core/theme/domain/entity/theme_entity.dart';
import '../../../features/auth/presentation/provider/auth_provider.dart';
import '../../../shared/widgets/reusable_card.dart';

// import Cubit quản lý rung
import '../../../core/services/vibration/vibration_cubit.dart';
import '../../../core/services/vibration/vibration_model.dart';

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

          // 🌙 Chế độ tối
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
                  onChanged: (_) => themeBloc.add(ToggleThemeEvent()),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔔 Cài đặt rung
          BlocBuilder<VibrationCubit, VibrationState>(
            builder: (context, state) {
              final cubit = context.read<VibrationCubit>();
              return ReusableCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.vibration),
                        SizedBox(width: 12),
                        Text("Cài đặt rung"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text("Bật rung"),
                      value: state.enabled,
                      onChanged: (v) => cubit.setEnabled(v),
                    ),
                    if (state.enabled) ...[
                      const Divider(),
                      const Text(
                        "Kiểu rung:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Column(
                        children: [
                          _vibrationOption(context, state, VibrationType.light, "Rung nhẹ"),
                          _vibrationOption(context, state, VibrationType.medium, "Rung vừa"),
                          _vibrationOption(context, state, VibrationType.strong, "Rung mạnh"),
                          _vibrationOption(context, state, VibrationType.pattern, "Rung theo nhịp"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Thử rung"),
                          onPressed: () => cubit.vibrateIfEnabled(),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // 🚪 Đăng xuất
          ReusableCard(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                authProvider.logout();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
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
                if (!mounted) return;
                context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget chọn kiểu rung
  Widget _vibrationOption(
      BuildContext context, VibrationState state, VibrationType type, String label) {
    final cubit = context.read<VibrationCubit>();
    return RadioListTile<VibrationType>(
      title: Text(label),
      value: type,
      groupValue: state.type,
      onChanged: (v) => cubit.setType(v!),
    );
  }
}
