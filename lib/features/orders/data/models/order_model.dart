import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    super.id,
    required super.userId,
    required super.totalAmount,
    super.currency,
    super.paymentStatus,
    super.orderStatus,
    super.createdAt,
    super.completedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] ?? json['order_status'] ?? 'pending';

    return OrderModel(
      id: json['\$id'],
      userId: json['user_id'] ?? json['customer_id'] ?? '',
      totalAmount: (
        json['total'] ??
        json['total_amount'] ??
        0
      ).toDouble(),
      currency: json['currency'],
      paymentStatus: json['payment_status'] ?? 'pending',
      orderStatus: status,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
    );
  }
}
