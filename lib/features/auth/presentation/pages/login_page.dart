// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart'; // Thêm SchedulerBinding

import '../../presentation/provider/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../utils/biometric_helper.dart';
import '../../../../core/router/app_router.dart';

// 🔔 THAY ĐỔI: Import VibrationType (Giả định nó là Enum trong vibration_model.dart)
import '../../../../core/services/vibration/vibration_service.dart';
import '../../../../core/services/vibration/vibration_model.dart'; // Chứa VibrationType Enum

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _canUseBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm hiển thị SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Theme.of(context).primaryColor,
        ),
      );
    });
  }

  // CHUYÊN NGHIỆP: Kiểm tra biometric và sự tồn tại của Auth Token (Refresh Token)
  Future<void> _checkBiometricAvailability() async {
    final available = await BiometricHelper.isBiometricAvailable();
    final authData = await BiometricHelper.getAuthData();

    // Chỉ bật _canUseBiometric nếu thiết bị hỗ trợ VÀ đã có token/userId được lưu
    if (available && authData != null) {
      setState(() {
        _canUseBiometric = true;
      });
    }
  }

  // ✅ SỬA LOGIC: Xử lý login bằng biometric
  Future<void> _onBiometricLogin() async {
    final authenticated = await BiometricHelper.authenticate();
    if (!mounted) return;

    if (authenticated) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.loginWithBiometric();

      if (!mounted) return;

      if (success) {
        // ✅ SỬA: Dùng VibrationType.success (đã được thêm vào enum trong bước trước)
        await VibrationService.vibrate(VibrationType.success);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập bằng vân tay thành công!'), backgroundColor: Colors.green),
        );
        // Điều hướng theo role
        final route = AppRouter.getHomeRouteByRole(authProvider.role);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go(route);
        });


      } else {
        // ✅ SỬA: Dùng VibrationType.error
        await VibrationService.vibrate(VibrationType.error);

        // Lỗi: Biometric thành công nhưng Refresh Token hết hạn/thất bại
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage ?? 'Phiên hết hạn, vui lòng đăng nhập thủ công.'), backgroundColor: Colors.red),
        );
      }
    } else {
      // ✅ SỬA: Dùng VibrationType.error
      await VibrationService.vibrate(VibrationType.error);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác thực vân tay thất bại!'), backgroundColor: Colors.orange),
      );
    }
  }

  // ✅ SỬA LOGIC: Xử lý login thủ công
  void _onLoginPressed() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // ✅ THAY ĐỔI LỚN: Gọi hàm login với cờ _rememberMe
      final success = await authProvider.login(email, password, _rememberMe);
      if (!mounted) return;

      if (success) {
        // ✅ SỬA: Dùng VibrationType.success
        await VibrationService.vibrate(VibrationType.success);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Đăng nhập thành công!"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Cập nhật lại trạng thái Biometric sau khi login/save token
        _checkBiometricAvailability();

        // Điều hướng theo role
        final route = AppRouter.getHomeRouteByRole(authProvider.role);
        context.go(route);

      } else {
        // ✅ SỬA: Dùng VibrationType.error
        await VibrationService.vibrate(VibrationType.error);

        // Hiển thị lỗi từ AuthProvider
        final errorMessage = authProvider.errorMessage ?? "Lỗi không xác định";
        ScaffoldMessenger.of(context).showSnackBar(_buildErrorSnackBar(errorMessage));
      }
    } catch (e) {
      if (!mounted) return;
      // ✅ SỬA: Dùng VibrationType.error
      await VibrationService.vibrate(VibrationType.error);

      // Hiển thị lỗi catch (nếu có)
      final errorMessage = authProvider.errorMessage ?? e.toString();
      ScaffoldMessenger.of(context).showSnackBar(_buildErrorSnackBar(errorMessage));
    }
  }


  SnackBar _buildErrorSnackBar(String message) {
    return SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    );
  }

  void _onForgotPasswordPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Tính năng quên mật khẩu sẽ được cập nhật sau"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.softBlack : AppColors.softWhite;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final isLoading = authProvider.isLoading;

            // Xử lý điều hướng nếu người dùng đã login và ở trang này
            if (authProvider.isAuthenticated && authProvider.isInitialCheckComplete) {
              final route = AppRouter.getHomeRouteByRole(authProvider.role);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                final currentPath = GoRouterState.of(context).uri.toString();
                if (currentPath == '/login') {
                  context.go(route);
                }
              });
              return const SizedBox.shrink();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Đăng nhập",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Chào mừng bạn quay lại!",
                    style: TextStyle(
                      fontSize: 18,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration('Email', Icons.email_outlined),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(
                            'Mật khẩu',
                            Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải ít nhất 6 ký tự';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: isLoading ? null : (value) {
                              setState(() => _rememberMe = value!);
                            },
                            activeColor: AppColors.primary,
                          ),
                          Text('Nhớ tài khoản', style: TextStyle(color: textColor.withOpacity(0.7))),
                        ],
                      ),
                      TextButton(
                        onPressed: isLoading ? null : _onForgotPasswordPressed,
                        child: Text(
                          'Quên mật khẩu?',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _onLoginPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Đăng nhập', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  if (_canUseBiometric) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _onBiometricLogin,
                      icon: const Icon(Icons.fingerprint, size: 24),
                      label: const Text('Đăng nhập bằng vân tay', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                      final success = await authProvider.loginWithGoogle();
                      if (!mounted) return;
                      if (success) {
                        final route = AppRouter.getHomeRouteByRole(authProvider.role);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.go(route);
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authProvider.errorMessage ?? 'Đăng nhập Google thất bại'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.white),
                    label: const Text("Đăng nhập bằng Google", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Chưa có tài khoản? ",
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading ? null : () {
                          context.go('/register');
                        },
                        child: Text(
                          "Đăng ký",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Bằng cách đăng nhập, bạn đồng ý với\nĐiều khoản sử dụng và Chính sách bảo mật",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor.withOpacity(0.5),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    icon: Icon(Icons.home_outlined, color: AppColors.primary),
                    label: Text(
                      "Trở về Trang chủ",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                      context.go('/home');
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, {Widget? suffixIcon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: isDark ? AppColors.secondary : AppColors.primary),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: isDark ? AppColors.softBlack : Colors.white,
      hintStyle: TextStyle(color: Colors.grey[500]),
    );
  }
}