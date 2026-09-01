import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_data_source.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderDataSource dataSource;

  OrderRepositoryImpl(this.dataSource);

  @override
  Future<List<Order>> getOrders(String userId) async {
    final models = await dataSource.getOrders(userId);
    return models.cast<Order>();
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    return await dataSource.getOrderById(orderId);
  }

  @override
  Future<Order> createOrder(Order order) async {
    final model = OrderModel(
      id: order.id,
      userId: order.userId,
      totalAmount: order.totalAmount,
      currency: order.currency,
      paymentStatus: order.paymentStatus,
      orderStatus: order.orderStatus,
      createdAt: order.createdAt,
      completedAt: order.completedAt,
    );
    return dataSource.createOrder(model);
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await dataSource.updateOrderStatus(orderId, status);
  }
}
