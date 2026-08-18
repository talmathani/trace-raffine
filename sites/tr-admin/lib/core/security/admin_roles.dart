enum AdminRole {
  owner,
  admin,
  moderator;

  static AdminRole? fromString(String value) {
    switch (value.toLowerCase()) {
      case 'owner':
        return AdminRole.owner;
      case 'admin':
        return AdminRole.admin;
      case 'moderator':
        return AdminRole.moderator;
      default:
        return null;
    }
  }

  bool get canManageUsers =>
      this == AdminRole.owner || this == AdminRole.admin;

  bool get canManageDesigns =>
      this == AdminRole.owner || this == AdminRole.admin;

  bool get canApproveDesigns =>
      this == AdminRole.owner ||
      this == AdminRole.admin ||
      this == AdminRole.moderator;

  bool get canDeleteDesigns =>
      this == AdminRole.owner || this == AdminRole.admin;

  bool get canManageOrders =>
      this == AdminRole.owner || this == AdminRole.admin;

  bool get canViewAuditLogs =>
      this == AdminRole.owner || this == AdminRole.admin;
}
