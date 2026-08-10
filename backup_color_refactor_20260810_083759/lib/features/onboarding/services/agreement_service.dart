import 'package:shared_preferences/shared_preferences.dart';

class AgreementService {
  static const String _customerPrefix = 'customer_agreement_accepted_';
  static const String _designerPrefix = 'designer_agreement_accepted_';
  static const String _administrationPrefix =
      'administration_agreement_accepted_';

  Future<bool> hasAccepted({required String uid, required String role}) async {
    final preferences = await SharedPreferences.getInstance();

    return preferences.getBool(_key(uid: uid, role: role)) ?? false;
  }

  Future<void> markAccepted({required String uid, required String role}) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_key(uid: uid, role: role), true);
  }

  String _key({required String uid, required String role}) {
    final prefix = switch (role) {
      'customer' => _customerPrefix,
      'designer' => _designerPrefix,
      'administration' => _administrationPrefix,
      _ => '${role}_agreement_accepted_',
    };

    return '$prefix$uid';
  }
}
