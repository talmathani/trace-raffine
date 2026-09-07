class Order {
  final String? id;
  final String userId;
  final double totalAmount;
  final String? currency;
  final String paymentStatus;
  final String orderStatus;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const Order({
    this.id,
    required this.userId,
    required this.totalAmount,
    this.currency,
    this.paymentStatus = 'pending',
    this.orderStatus = 'pending',
    this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': userId,
      'total': totalAmount,
      'currency': currency,
      'payment_status': paymentStatus,
      'status': orderStatus,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['\$id'],
      userId: json['customer_id'] ?? json['user_id'] ?? '',
      totalAmount: (json['total'] ?? json['total_amount'] ?? 0).toDouble(),
      currency: json['currency'],
      paymentStatus: json['payment_status'] ?? 'pending',
      orderStatus: json['status'] ?? json['order_status'] ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
    );
  }
}

