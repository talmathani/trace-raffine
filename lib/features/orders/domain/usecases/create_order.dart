import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository orderRepository;

  CreateOrderUseCase(this.orderRepository);

  Future<Order> call({
    required String userId,
    required List<Map<String, dynamic>> items,
    String currency = 'USD',
  }) async {
    double totalAmount = 0;
    for (final item in items) {
      totalAmount += (item['price'] ?? 0) * (item['quantity'] ?? 1);
    }

    final order = Order(
      userId: userId,
      totalAmount: totalAmount,
      currency: currency,
      paymentStatus: 'pending',
      orderStatus: 'pending',
    );

    return await orderRepository.createOrder(order);
  }
}
