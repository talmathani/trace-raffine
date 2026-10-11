enum OrderStatus { pending, approved, rejected }

class OrderModel {
  const OrderModel({
    required this.id,
    required this.customerId,
    required this.designId,
    required this.designerId,
    required this.amount,
    required this.status,
  });

  final String id;
  final String customerId;
  final String designId;
  final String designerId;
  final double amount;
  final OrderStatus status;

  factory OrderModel.fromFirestore(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      customerId: _stringValue(data['customerId']),
      designId: _stringValue(data['designId']),
      designerId: _stringValue(data['designerId']),
      amount: _doubleValue(data['amount']),
      status: _statusValue(data['status']),
    );
  }

  static OrderStatus _statusValue(dynamic value) {
    switch (value?.toString().trim().toLowerCase()) {
      case 'approved':
        return OrderStatus.approved;
      case 'rejected':
        return OrderStatus.rejected;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }

  static String _stringValue(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static double _doubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString().trim() ?? '') ?? 0;
  }
}
