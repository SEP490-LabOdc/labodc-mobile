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
import '../../../auth/presentation/utils/biometric_helper.dart';

class SplashPage extends StatefulWidget {
  // Đã xóa onFinish
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

    // BƯỚC 3: Xử lý Biometric Prompt nếu token có sẵn nhưng loadAuthState thất bại
    final bool isBiometricAvailable = await BiometricHelper.isBiometricAvailable();
    final authToken = await BiometricHelper.getAuthToken();

    if (authToken != null && isBiometricAvailable) {
      debugPrint('SplashPage: Chưa xác thực, nhưng có token và Biometric khả dụng. Hiển thị dialog.');
      final loginMethod = await _showLoginMethodDialog();
      if (!mounted) return;

      if (loginMethod == 'biometric') {
        final authenticated = await BiometricHelper.authenticate();
        if (authenticated) {
          final success = await authProvider.loginWithBiometric();
          if (success) {
            final route = AppRouter.getHomeRouteByRole(authProvider.role);
            debugPrint('SplashPage: Biometric thành công. Chuyển hướng đến $route');
            context.go(route);
            return;
          }
        }
      }
      debugPrint('SplashPage: Biometric thất bại/bị từ chối/Manual. Chuyển hướng đến ${Routes.login}');
      context.go(Routes.login);
      return;
    }

    // BƯỚC CUỐI: Chưa xác thực và không có Token/Biometric.
    debugPrint('SplashPage: Chưa xác thực và không có token. Chuyển hướng đến ${Routes.home}');
    context.go(Routes.home);
  }


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
    // Watch AuthProvider để rebuild khi trạng thái load thay đổi
    final authProvider = context.watch<AuthProvider>();

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isLight = themeState.themeEntity?.themeType == ThemeType.light;
        final bool shouldShowSpinner = !authProvider.isInitialCheckComplete;

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