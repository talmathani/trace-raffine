import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../../../../core/appwrite/appwrite_database_service.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final AppwriteDatabaseService _databaseService;

  OrderRepositoryImpl(this._databaseService);

  @override
  Future<List<Order>> getOrders(String userId) async {
    final response = await _databaseService.listDocuments(
      collectionId: AppwriteDatabaseConstants.ordersCollection,
    );
    return response.documents
        .map((doc) => OrderModel.fromJson({...doc.data, 'id': doc.$id}))
        .toList();
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _databaseService.getDocument(
        collectionId: AppwriteDatabaseConstants.ordersCollection,
        documentId: orderId,
      );
      return OrderModel.fromJson({...doc.data, 'id': doc.$id});
    } catch (_) {
      return null;
    }
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

    final doc = await _databaseService.createDocument(
      collectionId: AppwriteDatabaseConstants.ordersCollection,
      data: {
        'user_id': model.userId,
        'total_amount': model.totalAmount,
        'currency': model.currency,
        'payment_status': model.paymentStatus,
        'order_status': model.orderStatus,
        'created_at': model.createdAt?.toIso8601String(),
        'completed_at': model.completedAt?.toIso8601String(),
      },
      documentId: model.id != null && model.id!.isNotEmpty ? model.id : null,
    );

    return OrderModel.fromJson({...doc.data, 'id': doc.$id});
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _databaseService.updateDocument(
      collectionId: AppwriteDatabaseConstants.ordersCollection,
      documentId: orderId,
      data: {
        'order_status': status,
      },
    );
  }
}
