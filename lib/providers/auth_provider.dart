import 'package:flutter/material.dart';
import '../service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _authService.login(
        email: email,
        password: password,
      );

      _isLoggedIn = success;

      return success;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkLogin() async {
    final token = await _authService.getToken();

    _isLoggedIn = token != null;

    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();

    _isLoggedIn = false;

    notifyListeners();
  }
}