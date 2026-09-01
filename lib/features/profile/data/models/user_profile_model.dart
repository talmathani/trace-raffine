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
    final rawId = map['id'] ?? map['user_id'];

    if (rawId is! String || rawId.isEmpty) {
      throw const FormatException(
        'UserProfileModel: missing required user id.',
      );
    }

    final rawCreatedAt = map['createdAt'] ?? map['created_at'];

    if (rawCreatedAt is! String || rawCreatedAt.isEmpty) {
      throw const FormatException(
        'UserProfileModel: missing required created_at.',
      );
    }

    return UserProfileModel(
      id: rawId,
      email: map['email'] as String?,
      displayName:
          map['full_name'] as String? ??
          map['displayName'] as String? ??
          '',
      role: UserRoleX.fromValue(
        map['role'] as String? ?? 'customer',
      ),
      createdAt: DateTime.parse(rawCreatedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'email': email,
      'full_name': displayName,
      'role': role.value,
      'created_at': createdAt.toIso8601String(),
    };
  }
}