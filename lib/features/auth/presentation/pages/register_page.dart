import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';

/// Register Page
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Form key & controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _dob;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Xử lý khi nhấn nút đăng ký
  Future<void> _onRegisterPressed() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dob == null) {
      _showSnackbar("Vui lòng chọn ngày sinh");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final requestBody = {
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
        "confirmPassword": _confirmController.text.trim(),
        "phoneNumber": _phoneController.text.trim(),
        "dob": _dob!.toIso8601String(),
      };

      // TODO: gọi RegisterUseCase(requestBody)
      await Future.delayed(const Duration(seconds: 2)); // Fake API

      if (!mounted) return;
      _showSnackbar("Đăng ký thành công!");
      context.go('/login');
    } catch (e) {
      _showSnackbar("Đăng ký thất bại: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Hiển thị chọn ngày sinh
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      locale: const Locale('vi'),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _showSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.softBlack : AppColors.softWhite;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),

                /// Logo
                Image.asset("assets/images/logo.png", height: 120),
                const SizedBox(height: 32),

                /// Title
                Text(
                  "ĐĂNG KÝ",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),

                /// Email
                _buildTextField(
                  controller: _emailController,
                  hint: "Email",
                  icon: Icons.email_outlined,
                  validator: (value) =>
                  (value == null || value.isEmpty) ? "Vui lòng nhập email" : null,
                ),
                const SizedBox(height: 16),

                /// Password
                _buildTextField(
                  controller: _passwordController,
                  hint: "Mật khẩu",
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) =>
                  (value != null && value.length >= 6)
                      ? null
                      : "Mật khẩu phải từ 6 ký tự",
                ),
                const SizedBox(height: 16),

                /// Confirm Password
                _buildTextField(
                  controller: _confirmController,
                  hint: "Xác nhận mật khẩu",
                  icon: Icons.lock_reset,
                  obscureText: true,
                  validator: (value) =>
                  value == _passwordController.text ? null : "Mật khẩu không khớp",
                ),
                const SizedBox(height: 16),

                /// Phone
                _buildTextField(
                  controller: _phoneController,
                  hint: "Số điện thoại",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                  (value == null || value.isEmpty) ? "Vui lòng nhập số điện thoại" : null,
                ),
                const SizedBox(height: 16),

                /// DOB
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: _inputDecoration("Ngày sinh", Icons.cake),
                    child: Text(
                      _dob != null
                          ? DateFormat("dd/MM/yyyy").format(_dob!)
                          : "Chọn ngày sinh",
                      style: TextStyle(
                        color: _dob != null ? textColor : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Register Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onRegisterPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "ĐĂNG KÝ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// Link to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Đã có tài khoản?",
                      style: TextStyle(color: textColor.withOpacity(0.7)),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        "Đăng nhập",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  /// Reusable TextFormField
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: _inputDecoration(hint, icon),
    );
  }

  /// Input decoration
  InputDecoration _inputDecoration(String hint, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: isDark ? AppColors.secondary : AppColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: isDark ? AppColors.softBlack : Colors.white,
      hintStyle: TextStyle(color: Colors.grey[500]),
    );
  }
}
