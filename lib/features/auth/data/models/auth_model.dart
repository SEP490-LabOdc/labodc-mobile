// lib/features/auth/data/models/auth_model.dart
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({
    required super.accessToken,
    required super.refreshToken,
    required super.role,
    required super.userId,
    required super.fullName,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final token = json['accessToken']?.toString() ?? '';
    String userId = '';
    String role = 'user';

    if (token.isNotEmpty) {
      try {
        final Map<String, dynamic> payload = JwtDecoder.decode(token);

        userId = payload['userId']?.toString() ??
            payload['id']?.toString() ??
            payload['sub']?.toString() ??
            '';

        role = payload['role']?.toString() ?? 'user';

        debugPrint(
          '✅ [AuthModel] Decoded JWT → Role: $role | UserId: $userId',
        );
      } catch (e) {
        debugPrint('⚠️ [AuthModel] Decode JWT failed: $e');
      }
    } else {
      debugPrint('⚠️ [AuthModel] AccessToken is empty, cannot decode.');
    }

    if (userId.isEmpty) {
      debugPrint(
        '⚠️ [AuthModel] WARNING: userId không thể giải mã từ JWT.',
      );
    }

    return AuthModel(
      accessToken: token,
      refreshToken: json['refreshToken']?.toString() ?? '',
      role: role,
      userId: userId,
      fullName: json['fullName']?.toString() ?? '',
    );
  }
}
