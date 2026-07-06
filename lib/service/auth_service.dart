import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AuthService — menggunakan flutter_secure_storage
/// Token TIDAK disimpan dalam plain text (memenuhi kriteria Keamanan PKL).
///
/// Akun tersedia (simulasi API publik):
///   ADMIN : admin@lumina.edu   / admin123
///   MEMBER: alex@lumina.edu    / member123
///   MEMBER: sara@lumina.edu    / member123
class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyUserName = 'user_name';
  static const _keyUserId = 'user_id';
  static const _keyRole = 'user_role';
  static const _keyEmail = 'user_email';

  /// Daftar akun yang tersedia (simulasi dari API publik)
  static const List<Map<String, String>> _accounts = [
    {
      'id': 'usr_001',
      'name': 'Admin Lumina',
      'email': 'admin@lumina.edu',
      'password': 'admin123',
      'role': 'admin',
    },
    {
      'id': 'usr_002',
      'name': 'Alex Johnson',
      'email': 'alex@lumina.edu',
      'password': 'member123',
      'role': 'member',
    },
    {
      'id': 'usr_003',
      'name': 'Sara Wilson',
      'email': 'sara@lumina.edu',
      'password': 'member123',
      'role': 'member',
    },
  ];

  /// Login — cocokkan dengan daftar akun, simpan token ke secure storage
  Future<Map<String, String>?> login({
    required String email,
    required String password,
  }) async {
    // Cari akun yang cocok
    final account = _accounts.firstWhere(
      (a) =>
          a['email']!.toLowerCase() == email.toLowerCase() &&
          a['password'] == password,
      orElse: () => {},
    );

    if (account.isEmpty) return null;

    // Buat token JWT simulasi
    final token =
        'jwt_${account['id']}_${DateTime.now().millisecondsSinceEpoch}';

    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyUserName, value: account['name']!);
    await _storage.write(key: _keyUserId, value: account['id']!);
    await _storage.write(key: _keyRole, value: account['role']!);
    await _storage.write(key: _keyEmail, value: account['email']!);

    return {
      'id': account['id']!,
      'name': account['name']!,
      'email': account['email']!,
      'role': account['role']!,
      'token': token,
    };
  }

  /// Register — tambah akun baru (simulasi)
  Future<Map<String, String>?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.isEmpty || email.isEmpty || password.length < 6) return null;

    // Cek duplikat email
    final exists = _accounts.any(
      (a) => a['email']!.toLowerCase() == email.toLowerCase(),
    );
    if (exists) return null;

    final id = 'usr_${DateTime.now().millisecondsSinceEpoch}';
    final token = 'jwt_${id}_${DateTime.now().millisecondsSinceEpoch}';

    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyUserName, value: name);
    await _storage.write(key: _keyUserId, value: id);
    await _storage.write(key: _keyRole, value: 'member');
    await _storage.write(key: _keyEmail, value: email);

    return {
      'id': id,
      'name': name,
      'email': email,
      'role': 'member',
      'token': token,
    };
  }

  /// Logout — hapus semua data sesi
  Future<void> logout() async => await _storage.deleteAll();

  Future<String?> getToken() async => await _storage.read(key: _keyToken);
  Future<String?> getSavedUserName() async =>
      await _storage.read(key: _keyUserName);
  Future<String?> getSavedUserId() async =>
      await _storage.read(key: _keyUserId);
  Future<String?> getSavedRole() async => await _storage.read(key: _keyRole);
  Future<String?> getSavedEmail() async => await _storage.read(key: _keyEmail);

  /// Ambil semua akun member (untuk keperluan admin)
  List<Map<String, String>> getAllMembers() {
    return _accounts
        .where((a) => a['role'] == 'member')
        .map(
          (a) => {
            'id': a['id']!,
            'name': a['name']!,
            'email': a['email']!,
            'role': a['role']!,
          },
        )
        .toList();
  }
}
