import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> login(String email, String password);
  Future<AuthEntity> refreshToken(String refreshToken, String userId);
  Future<AuthEntity> loginWithGoogle(String googleToken);
}
