import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    super.id,
    required super.userId,
    required super.productId,
    super.quantity,
    super.createdAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['\$id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.tryParse(
        (json['created_at'] ?? json['\$createdAt'] ?? '').toString(),
      ),
    );
  }
}
