// lib/features/auth/presentation/provider/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../utils/biometric_helper.dart';
import '../utils/google_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  AuthEntity? _auth;
  bool _loading = false;
  String? _error;
  bool _isInitialCheckComplete = false;
  bool _hasAttemptedLoad = false;

  AuthProvider({required this.loginUseCase}) {
    debugPrint('AuthProvider: Khởi tạo và tải trạng thái.');
    loadAuthState();
  }

  // --- Getter ---
  bool get isLoading => _loading;
  String? get errorMessage => _error;
  String get role => _auth?.role ?? '';
  bool get isAuthenticated => _auth != null;
  bool get isInitialCheckComplete => _isInitialCheckComplete;
  AuthEntity? get currentUser => _auth;
  String? get accessToken => _auth?.accessToken;
  String? get refreshToken => _auth?.refreshToken;
  String get userId => _auth?.userId ?? '';

  // --- Tải lại trạng thái người dùng khi khởi động ---
  Future<void> loadAuthState() async {
    if (_hasAttemptedLoad) return;
    _hasAttemptedLoad = true;
    _loading = true;
    notifyListeners();

    try {
      final authData = await BiometricHelper.getAuthData();
      if (authData != null) {
        final repo = loginUseCase.repository;
        _auth = await repo.refreshToken(
          authData['refreshToken']!,
          authData['userId']!,
        );
      }
    } catch (e) {
      _auth = null;
      _error = e.toString();
    } finally {
      _isInitialCheckComplete = true;
      _loading = false;
      notifyListeners();
    }
  }

  // --- Đăng nhập thủ công ---
  Future<bool> login(String email, String password, bool rememberMe) async {
    _setLoading(true);
    try {
      _auth = await loginUseCase.call(email, password);

      if (_auth != null) {
        if (rememberMe) {
          await BiometricHelper.saveAuthData(_auth!.refreshToken, _auth!.userId);
        } else {
          await BiometricHelper.deleteCredentials();
        }

        debugPrint('✅ Login thủ công thành công.');
        return true;
      }
    } on Failure catch (f) {
      _error = f.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // --- Đăng nhập bằng sinh trắc học ---
  Future<bool> loginWithBiometric() async {
    final authData = await BiometricHelper.getAuthData();
    if (authData == null) return false;

    _setLoading(true);
    try {
      final repo = loginUseCase.repository;
      _auth = await repo.refreshToken(
        authData['refreshToken']!,
        authData['userId']!,
      );
      debugPrint('✅ Login Biometric thành công.');
      return true;
    } on Failure {
      _error = "Phiên đăng nhập hết hạn.";
      BiometricHelper.deleteCredentials();
      _auth = null;
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // --- Đăng nhập Google ---
  Future<bool> loginWithGoogle({bool rememberMe = true}) async {
    _setLoading(true);
    try {
      final idToken = await GoogleAuthService.signInWithGoogle();
      if (idToken == null) {
        _error = "Không thể lấy idToken từ Google.";
        return false;
      }

      final repo = loginUseCase.repository;
      _auth = await repo.loginWithGoogle(idToken);

      if (_auth != null) {
        if (_auth!.accessToken != null) {
          final decoded = JwtDecoder.decode(_auth!.accessToken!);
          debugPrint("[AuthProvider] Google login decoded: $decoded");
        }

        // ✅ Lưu refreshToken nếu cần
        if (rememberMe) {
          await BiometricHelper.saveAuthData(_auth!.refreshToken, _auth!.userId);
        }

        debugPrint("✅ AuthProvider: Google login success. Role: ${_auth?.role}");
        return true;
      } else {
        _error = "Không thể xác thực với server.";
        return false;
      }
    } on Failure catch (f) {
      _error = f.message;
    } catch (e) {
      _error = "Đăng nhập Google thất bại: $e";
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // --- Đăng xuất ---
  void logout() {
    _auth = null;
    _error = null;
    BiometricHelper.deleteCredentials();
    GoogleAuthService.signOut();
    notifyListeners();
  }

  // --- Helper ---
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
