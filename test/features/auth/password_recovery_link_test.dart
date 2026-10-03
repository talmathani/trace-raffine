import 'package:flutter_test/flutter_test.dart';

import 'package:trace_raffine/core/deep_link/app_deep_link_service.dart';

void main() {
  group('RecoveryLink', () {
    test('parses web recovery links', () {
      final link = RecoveryLink.fromUri(
        Uri.parse(
          'https://trace-raffine.app/reset-password'
          '?userId=user-123&secret=secret-456&expire=2030-01-01',
        ),
      );

      expect(link?.userId, 'user-123');
      expect(link?.secret, 'secret-456');
    });

    test('parses custom mobile recovery links', () {
      final link = RecoveryLink.fromUri(
        Uri.parse(
          'tracerafine://reset-password'
          '?userId=user-123&secret=secret-456',
        ),
      );

      expect(link?.userId, 'user-123');
      expect(link?.secret, 'secret-456');
    });

    test('rejects links without recovery credentials', () {
      expect(
        RecoveryLink.fromUri(
          Uri.parse('https://trace-raffine.app/reset-password'),
        ),
        isNull,
      );
    });

    test('rejects unrelated application links', () {
      expect(
        RecoveryLink.fromUri(
          Uri.parse(
            'https://trace-raffine.app/profile'
            '?userId=user-123&secret=secret-456',
          ),
        ),
        isNull,
      );
    });
  });
}
