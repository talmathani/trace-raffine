import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trace_raffine/domain/entities/user_role.dart';
import 'package:trace_raffine/features/auth/services/remembered_login_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores only login identity details when remember is enabled', () async {
    await RememberedLoginService.save(
      email: 'designer@example.com',
      role: UserRole.designer,
      remember: true,
    );

    final remembered = await RememberedLoginService.load();
    expect(remembered?.email, 'designer@example.com');
    expect(remembered?.role, UserRole.designer);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(RememberedLoginService.rememberKey), true);
    expect(preferences.getString(RememberedLoginService.emailKey),
        'designer@example.com');
    expect(preferences.getString(RememberedLoginService.roleKey), 'designer');
  });

  test('clears remembered details when remember is disabled', () async {
    await RememberedLoginService.save(
      email: 'customer@example.com',
      role: UserRole.customer,
      remember: true,
    );

    await RememberedLoginService.save(
      email: 'customer@example.com',
      role: UserRole.customer,
      remember: false,
    );

    expect(await RememberedLoginService.load(), isNull);
  });

  test('logout cleanup removes legacy details when remember is off', () async {
    SharedPreferences.setMockInitialValues({
      RememberedLoginService.rememberKey: false,
      RememberedLoginService.emailKey: 'legacy@example.com',
      RememberedLoginService.roleKey: 'customer',
    });

    await RememberedLoginService.clearIfNotRemembered();

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(RememberedLoginService.rememberKey), isNull);
    expect(preferences.getString(RememberedLoginService.emailKey), isNull);
    expect(preferences.getString(RememberedLoginService.roleKey), isNull);
  });
}
