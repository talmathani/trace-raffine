import 'package:appwrite/appwrite.dart';

import 'package:trace_raffine/core/appwrite/appwrite_database_constants.dart';
import 'package:trace_raffine/core/appwrite/appwrite_database_service.dart';
import 'package:trace_raffine/core/auth/current_user_service.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../models/favorite_model.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final AppwriteDatabaseService _databaseService;

  FavoriteRepositoryImpl(this._databaseService);

  Future<void> _requireCurrentUser(String userId) async {
    final currentUserId = await CurrentUserService.userId;
    if (currentUserId == null) {
      throw StateError('Authentication is required');
    }
    if (currentUserId != userId) {
      throw StateError('Authenticated user does not match favorite owner');
    }
  }

  @override
  Future<List<Favorite>> getFavorites(String userId) async {
    await _requireCurrentUser(userId);
    final response = await _databaseService.listDocuments(
      collectionId: AppwriteDatabaseConstants.favoritesCollectionId,
      queries: [Query.equal('user_id', userId), Query.orderDesc(r'$createdAt')],
    );

    return response.documents
        .map((doc) => FavoriteModel.fromJson({...doc.data, 'id': doc.$id}))
        .toList();
  }

  @override
  Future<Favorite> addFavorite(String userId, String productId) async {
    await _requireCurrentUser(userId);
    final existing = await _databaseService.listDocuments(
      collectionId: AppwriteDatabaseConstants.favoritesCollectionId,
      queries: [
        Query.equal('user_id', userId),
        Query.equal('product_id', productId),
        Query.limit(1),
      ],
    );

    if (existing.documents.isNotEmpty) {
      final doc = existing.documents.first;
      return FavoriteModel.fromJson({...doc.data, 'id': doc.$id});
    }

    final doc = await _databaseService.createDocument(
      collectionId: AppwriteDatabaseConstants.favoritesCollectionId,
      data: {'user_id': userId, 'product_id': productId},
      permissions: [
        Permission.read(Role.user(userId)),
        Permission.update(Role.user(userId)),
        Permission.delete(Role.user(userId)),
      ],
    );

    return FavoriteModel.fromJson({...doc.data, 'id': doc.$id});
  }

  @override
  Future<void> removeFavorite(String favoriteId) async {
    final currentUserId = await CurrentUserService.userId;
    if (currentUserId == null) {
      throw StateError('Authentication is required');
    }
    final favorite = await _databaseService.getDocument(
      collectionId: AppwriteDatabaseConstants.favoritesCollectionId,
      documentId: favoriteId,
    );
    if (favorite.data['user_id']?.toString() != currentUserId) {
      throw StateError('Favorite does not belong to authenticated user');
    }
    await _databaseService.deleteDocument(
      collectionId: AppwriteDatabaseConstants.favoritesCollectionId,
      documentId: favoriteId,
    );
  }

  @override
  Future<bool> isFavorite(String userId, String productId) async {
    await _requireCurrentUser(userId);
    final response = await _databaseService.listDocuments(
      collectionId: AppwriteDatabaseConstants.favoritesCollectionId,
      queries: [
        Query.equal('user_id', userId),
        Query.equal('product_id', productId),
        Query.limit(1),
      ],
    );

    return response.documents.isNotEmpty;
  }
}
