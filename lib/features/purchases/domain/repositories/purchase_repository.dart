import '../entities/purchase.dart';

abstract class PurchaseRepository {
  Future<List<Purchase>> getPurchases(String userId);
  Future<Purchase> addPurchase(Purchase purchase);
  Future<bool> hasPurchased(String userId, String productId);
}
