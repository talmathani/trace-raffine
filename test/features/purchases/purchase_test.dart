import 'package:flutter_test/flutter_test.dart';
import 'package:trace_raffine/features/purchases/domain/entities/purchase.dart';

void main() {
  group('Purchase', () {
    test('should create purchase', () {
      final purchase = Purchase(
        userId: 'user1',
        productId: 'prod1',
        orderId: 'order1',
      );

      expect(purchase.userId, 'user1');
      expect(purchase.productId, 'prod1');
      expect(purchase.orderId, 'order1');
    });

    test('should parse fromJson', () {
      final json = {
        '\$id': 'purchase1',
        'user_id': 'user1',
        'product_id': 'prod1',
        'order_id': 'order1',
      };

      final purchase = Purchase.fromJson(json);
      expect(purchase.id, 'purchase1');
      expect(purchase.productId, 'prod1');
    });
  });
}
