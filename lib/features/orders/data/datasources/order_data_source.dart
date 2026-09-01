import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../models/order_model.dart';

class OrderDataSource {
  final Databases databases;

  OrderDataSource(this.databases);

  factory OrderDataSource.create() {
    final client = AppwriteConfig.createClient();
    return OrderDataSource(Databases(client));
  }

  Future<List<OrderModel>> getOrders(String userId) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.ordersCollection,
      queries: [
        Query.equal('user_id', userId),
        Query.orderDesc('created_at'),
      ],
    );
    return response.documents.map((doc) => OrderModel.fromJson(doc.data)).toList();
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await databases.getDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.ordersCollection,
      documentId: orderId,
    );
    return OrderModel.fromJson(doc.data);
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    final doc = await databases.createDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.ordersCollection,
      documentId: ID.unique(),
      data: order.toJson(),
    );
    return OrderModel.fromJson(doc.data);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await databases.updateDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.ordersCollection,
      documentId: orderId,
      data: {'order_status': status},
    );
  }
}
