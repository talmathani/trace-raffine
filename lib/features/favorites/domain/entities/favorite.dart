class Favorite {
  final String? id;
  final String userId;
  final String productId;
  final DateTime? createdAt;

  const Favorite({
    this.id,
    required this.userId,
    required this.productId,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'product_id': productId};
  }

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['\$id'],
      userId: json['user_id'] ?? '',
      productId: json['product_id'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
