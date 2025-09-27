import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import '../../../../core/theme/domain/entity/theme_entity.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../auth/presentation/utils/biometric_helper.dart';

class SplashPage extends StatefulWidget {
  final Future<void> Function()? onFinish;

  const SplashPage({super.key, this.onFinish});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Tạo hiệu ứng fade-in
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Bắt đầu animation
    _animationController.forward();

    // Kiểm tra biometric và credentials ngay sau khi frame đầu tiên được vẽ
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
      final bool isBiometricAvailable = await BiometricHelper.isBiometricAvailable();
      final credentials = await BiometricHelper.getCredentials();

      if (isBiometricAvailable && credentials != null && !authProvider.isAuthenticated) {
        // Hiển thị dialog hỏi người dùng
        final loginMethod = await _showLoginMethodDialog();
        if (!mounted) return;

        if (loginMethod == 'biometric') {
          // Xử lý đăng nhập bằng vân tay
          final authenticated = await BiometricHelper.authenticate();
          if (authenticated) {
            final success = await authProvider.loginWithBiometric();
            if (success) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đăng nhập bằng vân tay thành công!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Điều hướng theo role
              final route = AppRouter.getHomeRouteByRole(authProvider.role);
              context.go(route);
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đăng nhập thất bại!'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.go('/login');
            }
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Xác thực vân tay thất bại!'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/login');
          }
        } else {
          // Người dùng chọn đăng nhập thủ công
          context.go('/login');
        }
      } else {
        // Không có biometric hoặc credentials, chạy logic onFinish
        if (widget.onFinish != null) {
          await widget.onFinish!();
        }
      }
    });
  }

  // Hiển thị dialog hỏi người dùng muốn đăng nhập bằng cách nào
  Future<String?> _showLoginMethodDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn cách đăng nhập'),
        content: const Text('Bạn muốn đăng nhập bằng vân tay hay nhập thủ công?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'manual'),
            child: const Text('Thủ công'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'biometric'),
            child: const Text('Vân tay'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isLight = state.themeEntity?.themeType == ThemeType.light;

        return Scaffold(
          backgroundColor: isLight ? AppColors.softWhite : AppColors.darkBackground,
          body: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: isLight ? AppColors.background : AppColors.darkPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isLight
                              ? Colors.black.withOpacity(0.1)
                              : Colors.white.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        'assets/images/logo-white-text.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tên ứng dụng
                  Text(
                    'LabODC',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isLight ? AppColors.textPrimary : AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Loading indicator
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isLight ? AppColors.primary : AppColors.darkPrimary,
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
}