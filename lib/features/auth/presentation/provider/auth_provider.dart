// lib/features/auth/presentation/provider/auth_provider.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart'; // THÊM IMPORT FAILURE
import '../../domain/entities/auth_entity.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../utils/biometric_helper.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  AuthEntity? _auth;
  bool _loading = false;
  String? _error;
  bool _isInitialCheckComplete = false;
  bool _hasAttemptedLoad = false;

  AuthProvider({required this.loginUseCase}) {
    debugPrint('AuthProvider: Khởi tạo. Bắt đầu loadAuthState.');
    loadAuthState();
  }

  // --- Getter ---
  String? get accessToken => _auth?.accessToken;
  String? get refreshToken => _auth?.refreshToken;
  bool get isLoading => _loading;
  String? get error => _error;
  String? get errorMessage => _error;
  String get role => _auth?.role ?? '';
  String get userId => _auth?.userId ?? '';
  bool get isAuthenticated => _auth != null;
  bool get isInitialCheckComplete => _isInitialCheckComplete;

  // Logic tải trạng thái đăng nhập ban đầu
  Future<void> loadAuthState() async {
    if (_hasAttemptedLoad) return;
    _hasAttemptedLoad = true;
    _loading = true;
    notifyListeners();

    try {
      final authData = await BiometricHelper.getAuthData();
      if (authData != null) {
        debugPrint('AuthProvider Debug: TÌM THẤY Refresh Token. Bắt đầu Refresh.');
        final authRepository = loginUseCase.repository;
        _auth = await authRepository.refreshToken(authData['refreshToken']!, authData['userId']!);
        debugPrint('AuthProvider Debug: Refresh Token THÀNH CÔNG. Role: ${_auth?.role}');
      } else {
        debugPrint('AuthProvider Debug: Không tìm thấy Refresh Token.');
      }
    } on Failure catch (f) { // CATCH FAILURE TẠI ĐÂY
      debugPrint('AuthProvider Debug: Refresh Token THẤT BẠI. Xóa Credentials. Lỗi: ${f.message}');
      BiometricHelper.deleteCredentials();
      _auth = null;
      _error = "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.";
    } catch (e) {
      // Bắt các lỗi khác (chủ yếu là lỗi lập trình)
      debugPrint('AuthProvider Debug: Refresh Token THẤT BẠI. Lỗi không xác định: $e');
      BiometricHelper.deleteCredentials();
      _auth = null;
      _error = "Lỗi hệ thống khi tải trạng thái. Vui lòng khởi động lại ứng dụng.";
    } finally {
      _isInitialCheckComplete = true;
      _loading = false;
      debugPrint('AuthProvider Debug: Load Auth State HOÀN TẤT. isAuthenticated: $isAuthenticated');
      notifyListeners();
    }
  }

  // ✅ ĐÃ SỬA: Khắc phục lỗi "might complete normally" bằng cách return false ở cuối
  Future<bool> login(String email, String password, bool rememberMe) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _auth = await loginUseCase.call(email, password);

      if (rememberMe && _auth != null) {
        await BiometricHelper.saveAuthData(_auth!.refreshToken, _auth!.userId);
      } else if (!rememberMe) {
        await BiometricHelper.deleteCredentials();
      }

      _loading = false;
      debugPrint('AuthProvider: Login thủ công thành công. Role: ${_auth?.role}');
      notifyListeners();
      return true; // THÀNH CÔNG: return true

    } on UnAuthorizedFailure {
      _error = "Sai tài khoản hoặc mật khẩu.";
    } on InvalidInputFailure catch (f) {
      _error = f.message;
    } on NetworkFailure catch (f) {
      _error = f.message;
    } on ServerFailure {
      _error = "Hệ thống đang bảo trì, vui lòng thử lại sau.";
    } on Failure catch (f) {
      _error = f.message;
    } catch (e) {
      _error = "Lỗi không xác định: Vui lòng liên hệ hỗ trợ.";
    }

    // LOGIC CHUNG CHO THẤT BẠI: Dọn dẹp trạng thái và return false
    _auth = null;
    _loading = false;
    debugPrint('AuthProvider: Login thủ công THẤT BẠI. Lỗi: $_error');
    notifyListeners();
    return false; // THẤT BẠI: return false
  }

  // ✅ LOGIC ĐĂNG NHẬP BẰNG BIOMETRIC (giữ nguyên logic đã có)
  Future<bool> loginWithBiometric() async {
    final authData = await BiometricHelper.getAuthData();
    if (authData == null) {
      _error = "Dữ liệu đăng nhập sinh trắc học không tìm thấy.";
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final authRepository = loginUseCase.repository;
      _auth = await authRepository.refreshToken(authData['refreshToken']!, authData['userId']!);

      _loading = false;
      debugPrint('AuthProvider: Login Biometric thành công. Role: ${_auth?.role}');
      notifyListeners();
      return true;
    } on Failure {
      _error = "Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.";
      BiometricHelper.deleteCredentials();
      _auth = null;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void logout() {
    _auth = null;
    _error = null;
    BiometricHelper.deleteCredentials();
    notifyListeners();
    debugPrint('AuthProvider: Đã Logout. isAuthenticated: $isAuthenticated');
  }
}