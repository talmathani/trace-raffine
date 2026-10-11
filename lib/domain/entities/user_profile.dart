import 'user_role.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.phone,
    required this.role,
    required this.createdAt,
    this.isSuspended = false,
    this.suspensionType = 'none',
    this.suspendedUntil,
    this.lastSeen,
  });

  final String id;
  final String? email;
  final String displayName;
  final String? phone;
  final UserRole role;
  final DateTime createdAt;
  final bool isSuspended;
  final String suspensionType;
  final DateTime? suspendedUntil;
  final DateTime? lastSeen;

  bool get isCurrentlySuspended {
    if (!isSuspended) return false;
    if (suspensionType == 'temporary' && suspendedUntil != null) {
      return DateTime.now().isBefore(suspendedUntil!);
    }
    return true;
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phone,
    UserRole? role,
    DateTime? createdAt,
    bool? isSuspended,
    String? suspensionType,
    DateTime? suspendedUntil,
    DateTime? lastSeen,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isSuspended: isSuspended ?? this.isSuspended,
      suspensionType: suspensionType ?? this.suspensionType,
      suspendedUntil: suspendedUntil ?? this.suspendedUntil,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
