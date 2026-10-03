import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_item_model.dart';
import '../../../../core/auth/current_user_service.dart';
import '../../../../core/functions/function_invoker.dart';

class CartRepositoryImpl implements CartRepository {
  final FunctionInvoker _functions;

  CartRepositoryImpl({FunctionInvoker? functions})
    : _functions = functions ?? FunctionInvoker.create();

  Future<String> _requireUser(String userId) async {
    final authenticatedUserId = await CurrentUserService.userId;
    if (authenticatedUserId == null || authenticatedUserId.isEmpty) {
      throw StateError('Authentication is required');
    }
    if (authenticatedUserId != userId) {
      throw StateError('Authenticated user does not match cart owner');
    }
    return authenticatedUserId;
  }

  CartItem _mapItem(Map<String, dynamic> data) {
    return CartItemModel.fromJson(data);
  }

  @override
  Future<List<CartItem>> getCartItems(String userId) async {
    final authenticatedUserId = await _requireUser(userId);
    final response = await _functions.listCartItems(
      userId: authenticatedUserId,
    );
    if (response['success'] != true) {
      throw StateError(response['error'] ?? 'Unable to load cart');
    }

    final documents = response['items'];
    if (documents is! List) {
      return const <CartItem>[];
    }

    return documents
        .whereType<Map>()
        .map((item) => _mapItem(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  @override
  Future<CartItem> addToCart(
    String userId,
    String productId, {
    int quantity = 1,
  }) async {
    final authenticatedUserId = await _requireUser(userId);
    if (productId.trim().isEmpty) {
      throw ArgumentError('productId is required');
    }
    if (quantity < 1) {
      throw ArgumentError('quantity must be greater than zero');
    }

    final response = await _functions.addCartItem(
      userId: authenticatedUserId,
      productId: productId,
      quantity: quantity,
    );
    if (response['success'] != true) {
      throw StateError(response['error'] ?? 'Unable to add item to cart');
    }

    final item = response['item'];
    if (item is! Map) {
      throw StateError('Cart item was not returned');
    }
    return _mapItem(Map<String, dynamic>.from(item));
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    final userId = await CurrentUserService.userId;
    if (userId == null || userId.isEmpty) {
      throw StateError('Authentication is required');
    }
    if (cartItemId.trim().isEmpty) {
      throw ArgumentError('cartItemId is required');
    }
    if (quantity < 1) {
      throw ArgumentError('quantity must be greater than zero');
    }

    final response = await _functions.updateCartItem(
      userId: userId,
      cartItemId: cartItemId,
      quantity: quantity,
    );
    if (response['success'] != true) {
      throw StateError(response['error'] ?? 'Unable to update cart item');
    }
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    final userId = await CurrentUserService.userId;
    if (userId == null || userId.isEmpty) {
      throw StateError('Authentication is required');
    }

    final response = await _functions.removeCartItem(
      userId: userId,
      cartItemId: cartItemId,
    );
    if (response['success'] != true) {
      throw StateError(response['error'] ?? 'Unable to remove cart item');
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    final authenticatedUserId = await _requireUser(userId);
    final response = await _functions.clearCart(userId: authenticatedUserId);
    if (response['success'] != true) {
      throw StateError(response['error'] ?? 'Unable to clear cart');
    }
  }
}
