import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:labodc_mobile/features/user_profile/domain/repositories/user_profile_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/get_it/get_it.dart';
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
  String get userName => _auth?.fullName ?? '';

  // ---------------------------------------------------------------------
  // LOAD USER PROFILE
  // ---------------------------------------------------------------------
  Future<void> _loadUserProfile() async {
    if (_auth == null) return;

    final repo = getIt<UserProfileRepository>();
    final result = await repo.getUserProfile(_auth!.userId);

    result.fold(
          (failure) {
        debugPrint("⚠️ Load profile failed: ${failure.message}");
      },
          (profile) {
        _auth = _auth!.copyWith(fullName: profile.fullName ?? '');
        notifyListeners();
      },
    );
  }

  // ---------------------------------------------------------------------
  // LOAD AUTH FROM TOKEN (APP START)
  // ---------------------------------------------------------------------
  Future<void> loadAuthState() async {
    if (_hasAttemptedLoad) return;
    _hasAttemptedLoad = true;

    _loading = true;
    notifyListeners();

    try {
      final stored = await BiometricHelper.getAuthData();
      if (stored != null) {
        final repo = loginUseCase.repository;

        _auth = await repo.refreshToken(
          stored['refreshToken']!,
          stored['userId']!,
        );

        // ⭐ Load profile sau khi refresh token
        await _loadUserProfile();
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

  Future<bool> login(String email, String password, bool rememberMe) async {
    _error = null;
    _setLoading(true);

    try {
      _auth = await loginUseCase.call(email, password);

      if (_auth != null) {
        if (rememberMe) {
          await BiometricHelper.saveAuthData(_auth!.refreshToken, _auth!.userId);
        } else {
          await BiometricHelper.deleteCredentials();
        }

        await _loadUserProfile();
        _isInitialCheckComplete = true;
        notifyListeners();
        return true;
      }
    } on Failure catch (f) {
      // SỬA: Lấy message từ Failure (đảm bảo tầng Data đã parse đúng "Dữ liệu không hợp lệ")
      _error = f.message;
      debugPrint("❌ Login Failure: ${f.message}");
    } catch (e) {
      _error = "Lỗi hệ thống: ${e.toString()}";
    } finally {
      // QUAN TRỌNG: Phải đảm bảo flag này luôn true để Router không nhảy về Splash
      _isInitialCheckComplete = true;
      _setLoading(false);
    }
    return false;
  }

  // ---------------------------------------------------------------------
  // LOGIN WITH BIOMETRIC
  // ---------------------------------------------------------------------
  Future<bool> loginWithBiometric() async {
    final saved = await BiometricHelper.getAuthData();
    if (saved == null) return false;

    _setLoading(true);
    try {
      final repo = loginUseCase.repository;

      _auth = await repo.refreshToken(
        saved['refreshToken']!,
        saved['userId']!,
      );

      await _loadUserProfile();

      return true;
    } catch (e) {
      _error = "Phiên đăng nhập hết hạn.";
      BiometricHelper.deleteCredentials();
      _auth = null;
    } finally {
      _setLoading(false);
    }
    return false;
  }

  // ---------------------------------------------------------------------
  // LOGIN WITH GOOGLE
  // ---------------------------------------------------------------------
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
        if (rememberMe) {
          await BiometricHelper.saveAuthData(_auth!.refreshToken, _auth!.userId);
        }

        await _loadUserProfile();
        return true;
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

  // ---------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------
  void logout() {
    _auth = null;
    _error = null;
    BiometricHelper.deleteCredentials();
    GoogleAuthService.signOut();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
