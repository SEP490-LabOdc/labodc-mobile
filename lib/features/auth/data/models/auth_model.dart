// lib/features/auth/data/models/auth_model.dart
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.accessToken,
    required super.refreshToken,
    required super.role,
    required super.userId,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final token = json['accessToken'] ?? '';
    final Map<String, dynamic> payload = JwtDecoder.decode(token);

    // ✅ SỬA LỖI: Ưu tiên lấy 'userId' (key chính xác theo payload bạn cung cấp),
    // sau đó mới đến 'id' và 'sub' (dành cho các cấu hình JWT khác)
    final String userId = payload['userId']?.toString() ?? payload['id']?.toString() ?? payload['sub']?.toString() ?? '';

    if (userId.isEmpty) {
      debugPrint('AuthModel WARNING: User ID không thể giải mã từ JWT (Key "userId", "id", và "sub" đều rỗng)!');
    }

    // DEBUG LOG: Kiểm tra Role và User ID được giải mã từ Access Token
    debugPrint('AuthModel Debug: Decoded Role: ${payload['role']} | Decoded User ID: $userId');

    return AuthModel(
      accessToken: token,
      refreshToken: json['refreshToken'] ?? '',
      role: payload['role'] ?? 'user',
      userId: userId,
    );
  }
}