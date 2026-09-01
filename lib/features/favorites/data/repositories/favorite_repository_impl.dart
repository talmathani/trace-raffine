import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_data_source.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteDataSource dataSource;

  FavoriteRepositoryImpl(this.dataSource);

  @override
  Future<List<Favorite>> getFavorites(String userId) async {
    final models = await dataSource.getFavorites(userId);
    return models.cast<Favorite>();
  }

  @override
  Future<Favorite> addFavorite(String userId, String productId) async {
    return await dataSource.addFavorite(userId, productId);
  }

  @override
  Future<void> removeFavorite(String favoriteId) async {
    await dataSource.removeFavorite(favoriteId);
  }

  @override
  Future<bool> isFavorite(String userId, String productId) async {
    return await dataSource.isFavorite(userId, productId);
  }
}
