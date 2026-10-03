import '../../domain/entities/purchase.dart';
import '../../domain/repositories/purchase_repository.dart';

class PurchaseProductUseCase {
  final PurchaseRepository purchaseRepository;

  PurchaseProductUseCase({required this.purchaseRepository});

  Future<Purchase> call({
    required String userId,
    required String productId,
    required String orderId,
  }) async {
    final hasPurchased = await purchaseRepository.hasPurchased(
      userId,
      productId,
    );
    if (hasPurchased) {
      throw Exception('Already purchased');
    }

    final purchase = Purchase(
      userId: userId,
      productId: productId,
      orderId: orderId,
      purchasedAt: DateTime.now(),
    );

    return await purchaseRepository.addPurchase(purchase);
  }
}
