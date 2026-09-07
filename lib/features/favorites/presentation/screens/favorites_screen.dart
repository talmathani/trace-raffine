import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/favorite.dart';
import '../providers/favorite_providers.dart';
import '../../../../core/auth/current_user_service.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  Future<List<Favorite>> _loadFavorites() async {
    final userId = await CurrentUserService.userId;
    if (userId == null) return [];

    return ref.read(favoriteRepositoryProvider).getFavorites(userId);
  }

  Future<void> _remove(String id) async {
    try {
      await ref.read(favoriteRepositoryProvider).removeFavorite(id);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر إزالة المفضلة: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: FutureBuilder<List<Favorite>>(
        future: _loadFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('تعذر تحميل المفضلة: ${snapshot.error}'),
            );
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.favorite),
                  title: Text(favorite.productId),
                  trailing: favorite.id == null
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _remove(favorite.id!),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
