import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartDataSource dataSource;

  CartRepositoryImpl(this.dataSource);

  @override
  Future<List<CartItem>> getCartItems(String userId) async {
    final models = await dataSource.getCartItems(userId);
    return models.cast<CartItem>();
  }

  @override
  Future<CartItem> addToCart(String userId, String productId, {int quantity = 1}) async {
    return await dataSource.addToCart(userId, productId, quantity: quantity);
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    await dataSource.updateQuantity(cartItemId, quantity);
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    await dataSource.removeFromCart(cartItemId);
  }

  @override
  Future<void> clearCart(String userId) async {
    await dataSource.clearCart(userId);
  }
}
