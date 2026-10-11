import 'package:flutter_test/flutter_test.dart';
import 'package:trace_raffine/features/orders/domain/entities/order.dart';

void main() {
  group('Order', () {
    test('should create order with defaults', () {
      final order = Order(
        userId: 'user1',
        totalAmount: 150.0,
      );

      expect(order.userId, 'user1');
      expect(order.totalAmount, 150.0);
      expect(order.paymentStatus, 'pending');
      expect(order.orderStatus, 'pending');
    });

    test('should parse fromJson', () {
      final json = {
        '\$id': 'order1',
        'user_id': 'user1',
        'total_amount': 200.0,
        'payment_status': 'paid',
        'order_status': 'completed',
      };

      final order = Order.fromJson(json);
      expect(order.id, 'order1');
      expect(order.totalAmount, 200.0);
      expect(order.paymentStatus, 'paid');
      expect(order.orderStatus, 'completed');
    });
  });
}
