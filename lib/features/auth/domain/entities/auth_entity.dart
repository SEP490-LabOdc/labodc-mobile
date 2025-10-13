// lib/features/auth/domain/entities/auth_entity.dart
class AuthEntity {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String userId;

  const AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.userId,
  });
}