
import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../models/product_model.dart';

class ProductDataSource {
  final Databases databases;
  final Storage storage;

  ProductDataSource(this.databases, this.storage);

  factory ProductDataSource.create() {
    final client = AppwriteConfig.createClient();
    return ProductDataSource(Databases(client), Storage(client));
  }

  ProductModel _toModel(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);
    final coverImage = normalized['cover_image_url'];
    if (coverImage is String &&
        coverImage.isNotEmpty &&
        !coverImage.startsWith('http')) {
      normalized['cover_image_url'] = storage
          .getFileView(
            bucketId: AppwriteConfig.designFilesBucketId,
            fileId: coverImage,
          )
          .toString();
    }
    return ProductModel.fromJson(normalized);
  }

  Future<List<ProductModel>> getProducts({int limit = 20, int offset = 0}) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: 'products',
      queries: [
        Query.equal('status', 'published'),
        Query.limit(limit),
        Query.offset(offset),
      ],
    );
    return response.documents.map((doc) => _toModel(doc.data)).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    final doc = await databases.getDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: 'products',
      documentId: id,
    );
    return ProductModel.fromJson(doc.data);
  }

  Future<List<ProductModel>> getProductsByDesigner(String designerId) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: 'products',
      queries: [
        Query.equal('designer_id', designerId),
      ],
    );
    return response.documents.map((doc) => ProductModel.fromJson(doc.data)).toList();
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    final doc = await databases.createDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: 'products',
      documentId: ID.unique(),
      data: product.toJson(),
    );
    return ProductModel.fromJson(doc.data);
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final doc = await databases.updateDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: 'products',
      documentId: product.id!,
      data: product.toJson(),
    );
    return ProductModel.fromJson(doc.data);
  }

  Future<void> deleteProduct(String id) async {
    await databases.deleteDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: 'products',
      documentId: id,
    );
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: 'products',
      queries: [
        Query.equal('status', 'published'),
        Query.search('title', query),
      ],
    );
    return response.documents.map((doc) => _toModel(doc.data)).toList();
  }
}
