class UserModel {
  final String id;
  final String name;
  final String email;
  final String token;
  final String role; // 'admin' | 'member'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    this.role = 'member',
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      role: json['role'] ?? 'member',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'role': role,
    };
  }
}
