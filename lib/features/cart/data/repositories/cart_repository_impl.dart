import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../../../../core/appwrite/appwrite_database_service.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final AppwriteDatabaseService _databaseService;

  CartRepositoryImpl(this._databaseService);

  @override
  Future<List<CartItem>> getCartItems(String userId) async {
    final response = await _databaseService.listDocuments(
      collectionId: AppwriteDatabaseConstants.cartCollectionId,
    );
    return response.documents
        .map((doc) => CartItemModel.fromJson({...doc.data, 'id': doc.$id}))
        .toList();
  }

  @override
  Future<CartItem> addToCart(String userId, String productId, {int quantity = 1}) async {
    final model = CartItemModel(
      id: '',
      userId: userId,
      productId: productId,
      quantity: quantity,
    );
    final doc = await _databaseService.createDocument(
      collectionId: AppwriteDatabaseConstants.cartCollectionId,
      data: {
        'user_id': model.userId,
        'product_id': model.productId,
        'quantity': model.quantity,
      },
    );
    return CartItemModel.fromJson({...doc.data, 'id': doc.$id});
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    await _databaseService.updateDocument(
      collectionId: AppwriteDatabaseConstants.cartCollectionId,
      documentId: cartItemId,
      data: {'quantity': quantity},
    );
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    await _databaseService.deleteDocument(
      collectionId: AppwriteDatabaseConstants.cartCollectionId,
      documentId: cartItemId,
    );
  }

  @override
  Future<void> clearCart(String userId) async {
    final response = await _databaseService.listDocuments(
      collectionId: AppwriteDatabaseConstants.cartCollectionId,
    );
    for (var doc in response.documents) {
      if (doc.data['user_id'] == userId) {
        await _databaseService.deleteDocument(
          collectionId: AppwriteDatabaseConstants.cartCollectionId,
          documentId: doc.$id,
        );
      }
    }
  }
}
