class AuthUserModel {
  final String id;
  final String mobile;
  final String name;
  final String role;
  final String token;

  const AuthUserModel({
    required this.id,
    required this.mobile,
    required this.name,
    required this.role,
    required this.token,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        '_id': id,
        'mobile': mobile,
        'name': name,
        'role': role,
        'token': token,
      };
}
