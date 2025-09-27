import 'dart:async';
import '../models/auth_model.dart';

class FakeAuthRemoteDataSource {
  // Fake user list
  final List<Map<String, dynamic>> _fakeUsers = [
    {
      "username": "talent@example.com",
      "password": "123456",
      "token": "fake-token-talent-001",
      "role": "talent"
    },
    {
      "username": "mentor@example.com",
      "password": "123456",
      "token": "fake-token-mentor-001",
      "role": "mentor"
    },
    {
      "username": "admin@example.com",
      "password": "123456",
      "token": "fake-token-admin-001",
      "role": "admin"
    },
    {
      "username": "company@example.com",
      "password": "123456",
      "token": "fake-token-company-001",
      "role": "company"
    }
  ];

  Future<AuthModel> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // giả lập network

    try {
      final user = _fakeUsers.firstWhere(
            (u) => u["username"] == username && u["password"] == password,
      );
      return AuthModel.fromJson(user);
    } catch (e) {
      throw Exception("Sai tài khoản hoặc mật khẩu");
    }
  }
}
