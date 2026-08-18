import '../../../core/security/admin_roles.dart';

final class AdminAccess {
  const AdminAccess({
    required this.userId,
    required this.roles,
  });

  final String userId;
  final List<AdminRole> roles;

  bool get isAdmin => roles.isNotEmpty;

  bool get isOwner => roles.contains(AdminRole.owner);

  bool get isAdministrator => roles.contains(AdminRole.admin);

  bool get isModerator => roles.contains(AdminRole.moderator);

  bool get canManageUsers =>
      roles.any((role) => role.canManageUsers);

  bool get canManageDesigns =>
      roles.any((role) => role.canManageDesigns);

  bool get canApproveDesigns =>
      roles.any((role) => role.canApproveDesigns);

  bool get canDeleteDesigns =>
      roles.any((role) => role.canDeleteDesigns);

  bool get canManageOrders =>
      roles.any((role) => role.canManageOrders);

  bool get canViewAuditLogs =>
      roles.any((role) => role.canViewAuditLogs);
}
