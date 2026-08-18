import '../repositories/order_repository.dart';

class CreateOrder {
  CreateOrder({required this._repository});

  final OrderRepository _repository;

  Future<String> call({
    required String customerId,
    required String designId,
    required String designerId,
    required double amount,
  }) {
    return _repository.createOrder(
      customerId: customerId,
      designId: designId,
      designerId: designerId,
      amount: amount,
    );
  }
}
