import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage storage =
      const FlutterSecureStorage();

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      await storage.write(
        key: "token",
        value: "login_success",
      );

      return true;
    }

    return false;
  }

  Future<void> logout() async {
    await storage.delete(key: "token");
  }

  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }
}