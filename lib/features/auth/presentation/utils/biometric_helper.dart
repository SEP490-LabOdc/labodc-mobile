// lib/features/auth/presentation/utils/biometric_helper.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart'; // Giữ nguyên import nếu có

/// Helper cho việc quản lý xác thực sinh trắc học và lưu trữ token an toàn.
class BiometricHelper {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Key an toàn để lưu trữ token và userId
  static const String _authTokenKey = 'auth_biometric_token';
  static const String _userIdKey = 'auth_user_id'; // KEY MỚI

  // ... (isBiometricAvailable, authenticate giữ nguyên) ...
  static Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics && await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Xác thực để đăng nhập',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // LƯU TOKEN và userId an toàn
  static Future<void> saveAuthData(String token, String userId) async {
    await _storage.write(key: _authTokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
  }

  // Lấy TOKEN và userId
  static Future<Map<String, String>?> getAuthData() async {
    final token = await _storage.read(key: _authTokenKey);
    final userId = await _storage.read(key: _userIdKey);

    if (token != null && userId != null) {
      return {'refreshToken': token, 'userId': userId};
    }
    return null;
  }

  // Lấy TOKEN (Dùng cho checkBiometricAvailability cũ nếu cần)
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  // Xóa token (khi logout)
  static Future<void> deleteCredentials() async {
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _userIdKey);
  }
}