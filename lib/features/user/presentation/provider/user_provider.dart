import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/use_cases/get_user_profile.dart';

class UserProvider extends ChangeNotifier {
  final GetUserProfile getUserProfile;

  UserEntity? _user;
  bool _loading = false;
  String? _error;

  UserProvider({required this.getUserProfile});

  UserEntity? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> fetchProfile(String token) async {
    _loading = true;
    notifyListeners();

    try {
      _user = await getUserProfile(token);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
