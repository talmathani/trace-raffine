import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../models/purchase_model.dart';

class PurchaseDataSource {
  final Databases databases;

  PurchaseDataSource(this.databases);

  factory PurchaseDataSource.create() {
    final client = AppwriteConfig.createClient();
    return PurchaseDataSource(Databases(client));
  }

  Future<List<PurchaseModel>> getPurchases(String userId) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.purchasesCollection,
      queries: [
        Query.equal('user_id', userId),
        Query.orderDesc('purchased_at'),
      ],
    );
    return response.documents.map((doc) => PurchaseModel.fromJson(doc.data)).toList();
  }

  Future<PurchaseModel> addPurchase(PurchaseModel purchase) async {
    final doc = await databases.createDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.purchasesCollection,
      documentId: ID.unique(),
      data: purchase.toJson(),
    );
    return PurchaseModel.fromJson(doc.data);
  }

  Future<bool> hasPurchased(String userId, String productId) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.purchasesCollection,
      queries: [
        Query.equal('user_id', userId),
        Query.equal('product_id', productId),
        Query.limit(1),
      ],
    );
    return response.documents.isNotEmpty;
  }
}
