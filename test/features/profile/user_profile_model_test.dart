import 'package:flutter_test/flutter_test.dart';
import 'package:trace_raffine/features/profile/data/models/user_profile_model.dart';
import 'package:trace_raffine/domain/entities/user_role.dart';

void main() {
  group('UserProfileModel', () {
    test('accepts explicit created_at from profile data', () {
      final profile = UserProfileModel.fromMap({
        'id': 'user-1',
        'email': 'a@example.com',
        'full_name': 'A',
        'role': 'customer',
        'created_at': '2026-09-30T00:00:00.000Z',
      });
      expect(profile.role, UserRole.customer);
      expect(profile.createdAt.toUtc().year, 2026);
    });

    test('falls back to Appwrite native createdAt', () {
      final profile = UserProfileModel.fromMap({
        'id': 'user-2',
        'email': 'b@example.com',
        'full_name': 'B',
        'role': 'designer',
        r'$createdAt': '2026-09-29T12:00:00.000Z',
      });
      expect(profile.role, UserRole.designer);
      expect(profile.createdAt.toUtc().day, 29);
    });

    test('rejects a profile with no creation timestamp', () {
      expect(
        () => UserProfileModel.fromMap({'id': 'user-3', 'role': 'customer'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
