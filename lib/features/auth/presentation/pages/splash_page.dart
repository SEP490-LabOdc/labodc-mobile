import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import '../../../../core/theme/domain/entity/theme_entity.dart';

const kSplashDelay = Duration(seconds: 2);

class SplashPage extends StatefulWidget {
  final Future<void> Function() onFinish;
  const SplashPage({super.key, required this.onFinish});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(kSplashDelay, () async {
      if (mounted) {
        await widget.onFinish();
        // Không gọi runApp trong onFinish, chỉ gọi context.go('/home') từ router.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isLight = state.themeEntity?.themeType == ThemeType.light;
        return Scaffold(
          backgroundColor: isLight ? AppColors.softWhite : AppColors.softBlack,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isLight
                        ? AppColors.background
                        : AppColors.darkBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/images/logo-white-text.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // const SizedBox(height: 32),
                // Text(
                //   "Fusion Lab",
                //   style: TextStyle(
                //     fontSize: 32,
                //     fontWeight: FontWeight.bold,
                //     color: isLight ? AppColors.primary : AppColors.darkPrimary,
                //     letterSpacing: 2,
                //   ),
                // ),
                // const SizedBox(height: 12),
                // Container(
                //   width: 60,
                //   height: 4,
                //   decoration: BoxDecoration(
                //     color: isLight ? AppColors.accent : AppColors.darkAccent,
                //     borderRadius: BorderRadius.circular(2),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
