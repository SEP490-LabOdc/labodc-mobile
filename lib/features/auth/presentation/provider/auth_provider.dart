import 'package:flutter/cupertino.dart';

import '../../domain/entities/auth_entity.dart';
import '../../domain/use_cases/login_use_case.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  AuthEntity? _auth;
  bool _loading = false;
  String? _error;

  AuthProvider({required this.loginUseCase});

  // --- Getter ---
  String? get token => _auth?.token;
  String? get role => _auth?.role ?? '';
  bool get isLoading => _loading;
  String? get error => _error;
  String? get errorMessage => _error;
  bool get isAuthenticated => _auth != null;

  // --- Actions ---
  Future<bool> login(String username, String password) async {
    _loading = true;
    notifyListeners();
    try {
      _auth = await loginUseCase(username, password);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void logout() {
    _auth = null;
    _error = null;
    notifyListeners();
  }

  bool hasRole(String role) {
    return _auth?.role == role;
  }
}