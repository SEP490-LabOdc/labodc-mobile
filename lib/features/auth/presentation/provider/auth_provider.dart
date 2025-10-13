// lib/features/auth/presentation/provider/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../utils/biometric_helper.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  AuthEntity? _auth;
  bool _loading = false;
  String? _error;
  bool _isInitialCheckComplete = false;

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

  // MỚI/SỬA: Logic tải trạng thái
  Future<void> loadAuthState() async {
    final authData = await BiometricHelper.getAuthData();

    if (authData != null) {
      // 💡 DEBUG LOG: KIỂM TRA REFRESH TOKEN VÀ USER ID ĐÃ LƯU
      debugPrint('AuthProvider Debug: TÌM THẤY Refresh Token. Token: ${authData['refreshToken']!.substring(0, 10)}... | UserID: ${authData['userId']}');

      try {
        final authRepository = loginUseCase.repository;
        // Thực hiện Refresh Token
        _auth = await authRepository.refreshToken(
          authData['refreshToken']!,
          authData['userId']!,
        );

        _error = null;
        debugPrint('AuthProvider Debug: Refresh Token THÀNH CÔNG. IsAuthenticated: true, Role: ${_auth?.role}');

      } catch (e) {
        _auth = null;
        _error = "Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại. Lỗi: ${e.toString()}";
        BiometricHelper.deleteCredentials();
        // 💡 DEBUG LOG: REFRESH THẤT BẠI
        debugPrint('AuthProvider Debug: Refresh Token THẤT BẠI. Xóa Credentials. Lỗi: $e');
      }
    } else {
      debugPrint('AuthProvider Debug: KHÔNG tìm thấy Refresh Token đã lưu.');
    }

    _isInitialCheckComplete = true;
    notifyListeners();
  }

  // ... (login) ...
  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _auth = await loginUseCase.call(email, password);
      _error = null;
      debugPrint('AuthProvider: Login thủ công thành công. Role: ${_auth?.role}');
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('AuthProvider: Login thủ công THẤT BẠI. Lỗi: $e');
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ... (loginWithBiometric) ...
  Future<bool> loginWithBiometric() async {
    final authData = await BiometricHelper.getAuthData();
    if (authData == null) return false;

    _loading = true;
    notifyListeners();

    try {
      final authRepository = loginUseCase.repository;
      _auth = await authRepository.refreshToken(authData['refreshToken']!, authData['userId']!);

      _error = null;
      debugPrint('AuthProvider: Login Biometric thành công. Role: ${_auth?.role}');
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.";
      BiometricHelper.deleteCredentials();
      debugPrint('AuthProvider: Login Biometric THẤT BẠI. Lỗi: $e');
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // MỚI/SỬA: Logic lưu token
  Future<void> saveBiometricToken() async {
    if (_auth != null) {
      // 💡 DEBUG LOG: XÁC NHẬN LƯU TOKEN
      debugPrint('AuthProvider Debug: Bắt đầu LƯU token an toàn. Token: ${_auth!.refreshToken.substring(0, 10)}...');
      await BiometricHelper.saveAuthData(_auth!.refreshToken, _auth!.userId);
      debugPrint('AuthProvider Debug: LƯU token an toàn THÀNH CÔNG.');
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