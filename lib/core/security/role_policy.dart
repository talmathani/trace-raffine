import '../../domain/entities/user_role.dart';

/// سياسة الأدوار المركزية للتطبيق.
///
/// البريد يحدد حساب الإدارة كحل توافق مع المتطلب الحالي، لكن يجب أن تبقى
/// صلاحيات Appwrite Teams/Permissions هي مصدر الحماية النهائي على الخادم.
abstract final class RolePolicy {
  static const adminEmail = 'tal.mathani9@gmail.com';

  static bool isAdminEmail(String? email) {
    return email?.trim().toLowerCase() == adminEmail;
  }

  static bool canUseRole({
    required String? email,
    required UserRole storedRole,
    required UserRole requestedRole,
  }) {
    return isAdminEmail(email) || storedRole == requestedRole;
  }
}
