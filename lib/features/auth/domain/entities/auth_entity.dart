// lib/features/auth/domain/entities/auth_entity.dart
class AuthEntity {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String userId;
  final String fullName;

  const AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.userId,
    required this.fullName,
  });

  AuthEntity copyWith({
    String? accessToken,
    String? refreshToken,
    String? role,
    String? userId,
    String? fullName,
  }) {
    return AuthEntity(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
    );
  }
}


