class Purchase {
  final String? id;
  final String userId;
  final String productId;
  final String orderId;
  final DateTime? purchasedAt;

  const Purchase({
    this.id,
    required this.userId,
    required this.productId,
    required this.orderId,
    this.purchasedAt,
  });

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'product_id': productId, 'order_id': orderId};
  }

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['\$id'],
      userId: json['user_id'] ?? '',
      productId: json['product_id'] ?? '',
      orderId: json['order_id'] ?? '',
      purchasedAt: json['purchased_at'] != null
          ? DateTime.tryParse(json['purchased_at'])
          : null,
    );
  }
}
