import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../models/cart_item_model.dart';

class CartDataSource {
  final Databases databases;

  CartDataSource(this.databases);

  factory CartDataSource.create() {
    final client = AppwriteConfig.createClient();
    return CartDataSource(Databases(client));
  }

  Future<List<CartItemModel>> getCartItems(String userId) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.cartItemsCollection,
      queries: [
        Query.equal('user_id', userId),
      ],
    );
    return response.documents.map((doc) => CartItemModel.fromJson(doc.data)).toList();
  }

  Future<CartItemModel> addToCart(String userId, String productId, {int quantity = 1}) async {
    final doc = await databases.createDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.cartItemsCollection,
      documentId: ID.unique(),
      data: {
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      },
    );
    return CartItemModel.fromJson(doc.data);
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    await databases.updateDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.cartItemsCollection,
      documentId: cartItemId,
      data: {'quantity': quantity},
    );
  }

  Future<void> removeFromCart(String cartItemId) async {
    await databases.deleteDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.cartItemsCollection,
      documentId: cartItemId,
    );
  }

  Future<void> clearCart(String userId) async {
    final items = await getCartItems(userId);
    for (final item in items) {
      if (item.id != null) {
        await removeFromCart(item.id!);
      }
    }
  }
}
