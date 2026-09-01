import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../models/favorite_model.dart';

class FavoriteDataSource {
  final Databases databases;

  FavoriteDataSource(this.databases);

  factory FavoriteDataSource.create() {
    final client = AppwriteConfig.createClient();
    return FavoriteDataSource(Databases(client));
  }

  Future<List<FavoriteModel>> getFavorites(String userId) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.favoritesCollection,
      queries: [
        Query.equal('user_id', userId),
      ],
    );
    return response.documents.map((doc) => FavoriteModel.fromJson(doc.data)).toList();
  }

  Future<FavoriteModel> addFavorite(String userId, String productId) async {
    final doc = await databases.createDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.favoritesCollection,
      documentId: ID.unique(),
      data: {
        'user_id': userId,
        'product_id': productId,
      },
    );
    return FavoriteModel.fromJson(doc.data);
  }

  Future<void> removeFavorite(String favoriteId) async {
    await databases.deleteDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.favoritesCollection,
      documentId: favoriteId,
    );
  }

  Future<bool> isFavorite(String userId, String productId) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.favoritesCollection,
      queries: [
        Query.equal('user_id', userId),
        Query.equal('product_id', productId),
        Query.limit(1),
      ],
    );
    return response.documents.isNotEmpty;
  }
}
