abstract class OrderRepository {
  Future<String> createOrder({
    required String customerId,
    required String designId,
    required String designerId,
    required double amount,
  });
}
