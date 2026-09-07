import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../../../../core/appwrite/appwrite_database_service.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../models/purchase_model.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final AppwriteDatabaseService _databaseService;

  PurchaseRepositoryImpl(this._databaseService);

  @override
  Future<List<Purchase>> getPurchases(String userId) async {
    final response = await _databaseService.listDocuments(
      collectionId: AppwriteDatabaseConstants.purchasesCollectionId,
    );

    return response.documents
        .map((doc) => PurchaseModel.fromJson({
              ...doc.data,
              r'$id': doc.$id,
            }))
        .where((purchase) => purchase.userId == userId)
        .toList();
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

    final documentId =
        model.id != null && model.id!.isNotEmpty ? model.id : null;

    final doc = await _databaseService.createDocument(
      collectionId: AppwriteDatabaseConstants.purchasesCollectionId,
      data: {
        'user_id': model.userId,
        'product_id': model.productId,
        'order_id': model.orderId,
        'purchased_at': model.purchasedAt?.toIso8601String(),
      },
      documentId: documentId,
    );

    return PurchaseModel.fromJson({
      ...doc.data,
      r'$id': doc.$id,
    });
  }

  @override
  Future<bool> hasPurchased(String userId, String productId) async {
    final purchases = await getPurchases(userId);
    return purchases.any((purchase) => purchase.productId == productId);
  }
}
