import '../entities/favorite.dart';

abstract class FavoriteRepository {
  Future<List<Favorite>> getFavorites(String userId);
  Future<Favorite> addFavorite(String userId, String productId);
  Future<void> removeFavorite(String favoriteId);
  Future<bool> isFavorite(String userId, String productId);
}
