enum UserRole { customer, designer }

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.designer:
        return 'designer';
    }
  }

  static UserRole fromValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'designer':
        return UserRole.designer;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }
}
