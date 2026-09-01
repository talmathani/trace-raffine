import '../../domain/entities/purchase.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../../orders/domain/repositories/order_repository.dart';

class PurchaseProductUseCase {
  final PurchaseRepository purchaseRepository;
  final OrderRepository orderRepository;

  PurchaseProductUseCase({
    required this.purchaseRepository,
    required this.orderRepository,
  });

  Future<Purchase> call({
    required String userId,
    required String productId,
    required String orderId,
  }) async {
    final hasPurchased = await purchaseRepository.hasPurchased(userId, productId);
    if (hasPurchased) {
      throw Exception('Already purchased');
    }

    final purchase = Purchase(
      userId: userId,
      productId: productId,
      orderId: orderId,
      purchasedAt: DateTime.now(),
    );

    final result = await purchaseRepository.addPurchase(purchase);
    await orderRepository.updateOrderStatus(orderId, 'completed');
    return result;
  }
}
