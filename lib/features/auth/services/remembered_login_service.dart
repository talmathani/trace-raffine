import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/user_role.dart';

class RememberedLogin {
  const RememberedLogin({required this.email, required this.role});

  final String email;
  final UserRole role;
}

class RememberedLoginService {
  const RememberedLoginService._();

  static const String rememberKey = 'remember_account';
  static const String emailKey = 'saved_login_email';
  static const String roleKey = 'saved_login_role';

  static Future<RememberedLogin?> load() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(rememberKey) != true) {
      return null;
    }

    final email = preferences.getString(emailKey)?.trim();
    final roleName = preferences.getString(roleKey);
    if (email == null || email.isEmpty || roleName == null) {
      return null;
    }

    final role = UserRole.values.firstWhere(
      (value) => value.name == roleName,
      orElse: () => UserRole.customer,
    );

    return RememberedLogin(email: email, role: role);
  }

  static Future<void> save({
    required String email,
    required UserRole role,
    required bool remember,
  }) async {
    if (!remember) {
      await clear();
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(rememberKey, true);
    await preferences.setString(emailKey, email.trim());
    await preferences.setString(roleKey, role.name);
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(rememberKey);
    await preferences.remove(emailKey);
    await preferences.remove(roleKey);
  }

  static Future<void> clearIfNotRemembered() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(rememberKey) == true) {
      return;
    }

    await preferences.remove(emailKey);
    await preferences.remove(roleKey);
    await preferences.remove(rememberKey);
  }
}
