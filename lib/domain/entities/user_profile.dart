import 'user_role.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String? email;
  final String displayName;
  final UserRole role;
  final DateTime createdAt;

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
