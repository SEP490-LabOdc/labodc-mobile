import 'package:flutter/material.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/use_cases/login_use_case.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  AuthEntity? _auth;
  bool _loading = false;
  String? _error;

  AuthProvider({required this.loginUseCase});

  String? get token => _auth?.token;
  bool get isLoading => _loading;
  String? get error => _error;

  // 👉 Thêm getter này
  String? get errorMessage => _error;

  bool get isAuthenticated => _auth != null;

  Future<bool> login(String username, String password) async {
    _loading = true;
    notifyListeners();
    try {
      _auth = await loginUseCase(username, password);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void logout() {
    _auth = null;
    notifyListeners();
  }

  bool hasRole(String role) {
    if (role == 'admin') {
      return token?.contains("admin") ?? false;
    }
    return true;
  }
}

