import 'package:trace_raffine/core/appwrite/appwrite_service.dart';
import 'package:trace_raffine/core/functions/function_invoker.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FunctionInvoker _functionInvoker;

  OrderRepositoryImpl({FunctionInvoker? functionInvoker})
    : _functionInvoker = functionInvoker ?? FunctionInvoker.create();

  @override
  Future<List<Order>> getOrders(String userId) async {
    final result = await _functionInvoker.listOrders(userId: userId);
    if (result['success'] != true) {
      throw StateError(result['error']?.toString() ?? 'Unable to load orders.');
    }

    final orders = result['orders'];
    if (orders is! List) return const <Order>[];

    return orders
        .whereType<Map>()
        .map((raw) {
          final data = raw['data'] is Map
              ? Map<String, dynamic>.from(raw['data'] as Map)
              : Map<String, dynamic>.from(raw);
          final id = raw['\$id']?.toString() ?? raw['id']?.toString();
          if (id != null && id.isNotEmpty) data['\$id'] = id;
          return OrderModel.fromJson(data);
        })
        .toList(growable: false);
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    final userId = (await AppwriteService.account.get()).$id;
    if (userId.isEmpty) return null;

    final result = await _functionInvoker.getOrder(
      userId: userId,
      orderId: orderId,
    );
    if (result['success'] != true) return null;

    final raw = result['order'];
    if (raw is! Map) return null;
    final data = raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : Map<String, dynamic>.from(raw);
    final id = raw['\$id']?.toString() ?? raw['id']?.toString() ?? orderId;
    data['\$id'] = id;
    return OrderModel.fromJson(data);
  }

  @override
  Future<Order> createOrder(
    Order order,
    List<Map<String, dynamic>> items,
  ) async {
    final result = await _functionInvoker.createOrder(
      userId: order.userId,
      items: items,
      currency: order.currency ?? 'USD',
    );

    if (result['success'] != true) {
      throw StateError(result['error']?.toString() ?? 'Order creation failed.');
    }

    final orderId = result['orderId']?.toString().trim() ?? '';
    if (orderId.isEmpty) {
      throw StateError('Order creation succeeded without an orderId.');
    }

    final createdOrder = await getOrderById(orderId);
    if (createdOrder == null) {
      throw StateError(
        'Order $orderId was created but could not be read back.',
      );
    }

    return createdOrder;
  }
}
