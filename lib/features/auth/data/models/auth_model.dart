import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({required super.token, required super.role});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(token: json['token'], role: json['role']);
  }
}
