import '../../../../domain/entities/user_profile.dart';
import '../../../../domain/entities/user_role.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.phone,
    required super.role,
    required super.createdAt,
    super.isSuspended = false,
    super.suspensionType = 'none',
    super.suspendedUntil,
    super.lastSeen,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'] ?? map['user_id'];

    if (rawId is! String || rawId.isEmpty) {
      throw const FormatException(
        'UserProfileModel: missing required user id.',
      );
    }

    final rawCreatedAt =
        map['createdAt'] ?? map['created_at'] ?? map[r'$createdAt'];

    if (rawCreatedAt is! String || rawCreatedAt.isEmpty) {
      throw const FormatException(
        'UserProfileModel: missing required created_at.',
      );
    }

    return UserProfileModel(
      id: rawId,
      email: map['email'] as String?,
      displayName:
          map['full_name'] as String? ?? map['displayName'] as String? ?? '',
      phone: map['phone'] as String?,
      role: UserRoleX.fromValue(map['role'] as String? ?? 'customer'),
      createdAt: DateTime.parse(rawCreatedAt),
      isSuspended: map['is_suspended'] == true,
      suspensionType: map['suspension_type'] as String? ?? 'none',
      suspendedUntil: _parseDate(map['suspended_until']),
      lastSeen: _parseDate(map['last_seen']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'email': email,
      'full_name': displayName,
      'phone': phone,
      'role': role.value,
      'created_at': createdAt.toIso8601String(),
      'is_suspended': isSuspended,
      'suspension_type': suspensionType,
      if (suspendedUntil != null)
        'suspended_until': suspendedUntil!.toIso8601String(),
      if (lastSeen != null) 'last_seen': lastSeen!.toIso8601String(),
    };
  }
}
