// lib/features/auth/presentation/pages/splash_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Thêm để dùng debugPrint
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import '../../../../core/theme/domain/entity/theme_entity.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
// import '../../../auth/presentation/utils/biometric_helper.dart'; // Đã loại bỏ import không cần thiết

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _startInitialCheckAndNavigate();
  }

  // LOGIC ĐIỀU HƯỚNG CHÍNH
  void _startInitialCheckAndNavigate() async {
    debugPrint('SplashPage: Bắt đầu _startInitialCheckAndNavigate.');
    _animationController.forward();

    // Chờ animation và đảm bảo AuthProvider đã hoàn tất kiểm tra
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // BƯỚC 1: CHỜ AuthProvider HOÀN TẤT VIỆC KIỂM TRA TRẠNG THÁI
    if (!authProvider.isInitialCheckComplete) {
      debugPrint('SplashPage: AuthProvider chưa hoàn tất. Bắt đầu chờ...');
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        return !authProvider.isInitialCheckComplete;
      });
      debugPrint('SplashPage: AuthProvider đã hoàn tất việc chờ.');
    }

    debugPrint('SplashPage: Trạng thái cuối cùng: isAuthenticated: ${authProvider.isAuthenticated}, Role: ${authProvider.role}');

    // BƯỚC 2: Điều hướng nếu đã xác thực
    if (authProvider.isAuthenticated) {
      final route = AppRouter.getHomeRouteByRole(authProvider.role);
      debugPrint('SplashPage: Đã xác thực. Chuyển hướng đến $route');
      context.go(route);
      return;
    }

    // BƯỚC CUỐI: Chưa xác thực. Chuyển hướng đến trang Home công cộng.
    // Nếu người dùng cố gắng vào protected route sau đó, GoRouter sẽ chuyển họ đến /login.
    debugPrint('SplashPage: Chưa xác thực. Chuyển hướng đến ${Routes.home}');
    context.go(Routes.home);
  }

  // Đã loại bỏ _showLoginMethodDialog

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch AuthProvider để rebuild khi trạng thái load thay đổi
    final authProvider = context.watch<AuthProvider>();

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isLight = themeState.themeEntity?.themeType == ThemeType.light;
        final bool shouldShowSpinner = !authProvider.isInitialCheckComplete;

        // Chọn màu dựa trên theme
        final Color primaryColor = isLight ? AppColors.primary : AppColors.darkPrimary;

        return Scaffold(
          backgroundColor: isLight ? AppColors.softWhite : AppColors.darkBackground,
          body: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ... (UI giữ nguyên)
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
                  if (shouldShowSpinner)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
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