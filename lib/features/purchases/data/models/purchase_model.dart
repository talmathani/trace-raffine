import '../../domain/entities/purchase.dart';

class PurchaseModel extends Purchase {
  const PurchaseModel({
    super.id,
    required super.userId,
    required super.productId,
    required super.orderId,
    super.purchasedAt,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['\$id'],
      userId: json['user_id'] ?? '',
      productId: json['product_id'] ?? '',
      orderId: json['order_id'] ?? '',
      purchasedAt: json['purchased_at'] != null ? DateTime.tryParse(json['purchased_at']) : null,
    );
  }
}
