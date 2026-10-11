import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems(String userId);
  Future<CartItem> addToCart(
    String userId,
    String productId, {
    int quantity = 1,
  });
  Future<void> updateQuantity(String cartItemId, int quantity);
  Future<void> removeFromCart(String cartItemId);
  Future<void> clearCart(String userId);
}
