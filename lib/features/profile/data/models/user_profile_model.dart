import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/entities/user_role.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.displayName,
    required super.role,
    required super.createdAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRole.customer,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
