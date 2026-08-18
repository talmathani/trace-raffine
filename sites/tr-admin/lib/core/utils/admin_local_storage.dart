import 'package:shared_preferences/shared_preferences.dart';

final class AdminLocalStorage {
  AdminLocalStorage._();

  static const String _rememberAccountKey =
      'tr_admin_remember_account';

  static const String _rememberedEmailKey =
      'tr_admin_remembered_email';

  static Future<void> saveRememberedEmail(String email) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(
      _rememberAccountKey,
      true,
    );

    await preferences.setString(
      _rememberedEmailKey,
      email.trim(),
    );
  }

  static Future<String?> getRememberedEmail() async {
    final preferences = await SharedPreferences.getInstance();

    final rememberAccount =
        preferences.getBool(_rememberAccountKey) ?? false;

    if (!rememberAccount) {
      return null;
    }

    final email =
        preferences.getString(_rememberedEmailKey)?.trim();

    if (email == null || email.isEmpty) {
      return null;
    }

    return email;
  }

  static Future<void> clearRememberedAccount() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_rememberAccountKey);
    await preferences.remove(_rememberedEmailKey);
  }
}
