import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  static const _accessTokenKey = "accessToken";
  static const _refreshTokenKey = "refreshToken";
  static const _userIdKey = "userId";

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await storage.write(key: _accessTokenKey, value: accessToken);
    await storage.write(key: _refreshTokenKey, value: refreshToken);
    await storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getAccessToken() => storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => storage.read(key: _refreshTokenKey);

  Future<String?> getUserId() => storage.read(key: _userIdKey);

  Future<void> clear() async {
    await storage.deleteAll();
  }
}
