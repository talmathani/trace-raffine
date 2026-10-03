import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders(String userId);
  Future<Order?> getOrderById(String orderId);
  Future<Order> createOrder(Order order, List<Map<String, dynamic>> items);
}
