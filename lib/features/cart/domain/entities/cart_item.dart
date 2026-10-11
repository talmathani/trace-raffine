class CartItem {
  final String? id;
  final String userId;
  final String productId;
  final int quantity;
  final DateTime? createdAt;

  const CartItem({
    this.id,
    required this.userId,
    required this.productId,
    this.quantity = 1,
    this.createdAt,
  });

  CartItem copyWith({
    String? id,
    String? userId,
    String? productId,
    int? quantity,
    DateTime? createdAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'product_id': productId, 'quantity': quantity};
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
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
