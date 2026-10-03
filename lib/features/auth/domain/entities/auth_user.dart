class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.emailVerified,
    this.name = '',
    this.phone = '',
  });

  final String id;
  final String email;
  final bool emailVerified;
  final String name;
  final String phone;

  AuthUser copyWith({
    String? id,
    String? email,
    bool? emailVerified,
    String? name,
    String? phone,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}
