import '../../domain/entities/purchase.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_data_source.dart';
import '../models/purchase_model.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseDataSource dataSource;

  PurchaseRepositoryImpl(this.dataSource);

  @override
  Future<List<Purchase>> getPurchases(String userId) async {
    final models = await dataSource.getPurchases(userId);
    return models.cast<Purchase>();
  }

  @override
  Future<Purchase> addPurchase(Purchase purchase) async {
    final model = PurchaseModel(
      id: purchase.id,
      userId: purchase.userId,
      productId: purchase.productId,
      orderId: purchase.orderId,
      purchasedAt: purchase.purchasedAt,
    );
    return dataSource.addPurchase(model);
  }

  @override
  Future<bool> hasPurchased(String userId, String productId) async {
    return await dataSource.hasPurchased(userId, productId);
  }
}
