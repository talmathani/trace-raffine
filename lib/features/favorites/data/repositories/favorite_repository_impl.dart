import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../../../../core/appwrite/appwrite_database_service.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../models/favorite_model.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final AppwriteDatabaseService _databaseService;

  FavoriteRepositoryImpl(this._databaseService);

  @override
  Future<List<Favorite>> getFavorites(String userId) async {
    final response = await _databaseService.listDocuments(
      collectionId: AppwriteDatabaseConstants.favoritesCollectionId,
    );
    return response.documents
        .map((doc) => FavoriteModel.fromJson({...doc.data, 'id': doc.$id}))
        .where((fav) => fav.userId == userId)
        .toList();
  }

  @override
  Future<Favorite> addFavorite(String userId, String productId) async {
    final model = FavoriteModel(
      id: '',
      userId: userId,
      productId: productId,
    );
    final doc = await _databaseService.createDocument(
      collectionId: AppwriteDatabaseConstants.favoritesCollectionId,
      data: {
        'user_id': model.userId,
        'product_id': model.productId,
      },
    );
    return FavoriteModel.fromJson({...doc.data, 'id': doc.$id});
  }

  @override
  Future<void> removeFavorite(String favoriteId) async {
    await _databaseService.deleteDocument(
      collectionId: AppwriteDatabaseConstants.favoritesCollectionId,
      documentId: favoriteId,
    );
  }

  @override
  Future<bool> isFavorite(String userId, String productId) async {
    final favorites = await getFavorites(userId);
    return favorites.any((fav) => fav.productId == productId);
  }
}
