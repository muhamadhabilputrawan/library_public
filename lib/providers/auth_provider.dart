import 'package:flutter/material.dart';
import '../service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String _userName = '';
  String _userId = '';
  String _userEmail = '';
  String _role = 'member'; // 'admin' | 'member'
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userId => _userId;
  String get userEmail => _userEmail;
  String get role => _role;
  String get errorMessage => _errorMessage;
  bool get isAdmin => _role == 'admin';

  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final result = await _authService.login(email: email, password: password);

      if (result != null) {
        _isLoggedIn = true;
        _userName = result['name']!;
        _userId = result['id']!;
        _userEmail = result['email']!;
        _role = result['role']!;
        return true;
      }

      _errorMessage = 'Email atau password salah.';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      if (result != null) {
        _isLoggedIn = true;
        _userName = result['name']!;
        _userId = result['id']!;
        _userEmail = result['email']!;
        _role = result['role']!;
        return true;
      }

      _errorMessage = 'Email sudah terdaftar atau data tidak valid.';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkLogin() async {
    final token = await _authService.getToken();
    _isLoggedIn = token != null;
    if (_isLoggedIn) {
      _userName = await _authService.getSavedUserName() ?? '';
      _userId = await _authService.getSavedUserId() ?? '';
      _role = await _authService.getSavedRole() ?? 'member';
      _userEmail = await _authService.getSavedEmail() ?? '';
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _userName = '';
    _userId = '';
    _userEmail = '';
    _role = 'member';
    notifyListeners();
  }

  /// Ambil daftar member untuk admin
  List<Map<String, String>> getAllMembers() {
    return _authService.getAllMembers();
  }
}
