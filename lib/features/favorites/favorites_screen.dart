import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_raffine/core/appwrite/appwrite_config.dart';
import 'package:trace_raffine/core/auth/current_user_service.dart';
import 'package:trace_raffine/core/di/app_dependencies.dart';
import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/appwrite_image.dart';
import 'package:trace_raffine/core/ui/editorial_button.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';

import '../products/domain/entities/product.dart';
import '../products/product_details_screen.dart';
import 'domain/entities/favorite.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  late Future<List<Favorite>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavorites();
  }

  Future<List<Favorite>> _loadFavorites() async {
    final userId = await CurrentUserService.userId;
    if (userId == null) return [];

    return ref.read(favoriteRepositoryProvider).getFavorites(userId);
  }

  Future<Product?> _loadProduct(String productId) {
    return ref.read(productRepositoryProvider).getProductById(productId);
  }

  Future<void> _refresh() async {
    setState(() {
      _favoritesFuture = _loadFavorites();
    });
    await _favoritesFuture;
  }

  Future<void> _remove(String id) async {
    try {
      await ref.read(favoriteRepositoryProvider).removeFavorite(id);

      if (!mounted) return;

      setState(() {
        _favoritesFuture = _loadFavorites();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إزالة التصميم من المفضلة'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر إزالة التصميم من المفضلة: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
    ).then((_) {
      if (mounted) {
        setState(() {
          _favoritesFuture = _loadFavorites();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: MaisonAppBar(title: 'المفضلة'),
      body: FutureBuilder<List<Favorite>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _FavoritesLoadingState();
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: 'تعذر تحميل المفضلة',
              onRetry: _refresh,
            );
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return const _EmptyFavoritesState();
          }

          return RefreshIndicator(
            color: AppTheme.roseBurgundy,
            backgroundColor: AppTheme.secondarySurface,
            onRefresh: _refresh,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: context.responsiveContentMaxWidth,
                ),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    context.responsiveHorizontalPadding,
                    context.isCompact ? 22 : 30,
                    context.responsiveHorizontalPadding,
                    56,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<Product?>(
                      future: _loadProduct(favorites[index].productId),
                      builder: (context, productSnapshot) {
                        if (productSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const _ProductLoadingEntry();
                        }

                        final product = productSnapshot.data;

                        if (product == null) {
                          return _UnavailableFavoriteEntry(
                            favorite: favorites[index],
                            onRemove: favorites[index].id == null
                                ? null
                                : () => _remove(favorites[index].id!),
                          );
                        }

                        return _FavoriteProductEntry(
                          index: index,
                          product: product,
                          onTap: () => _openProduct(product),
                          onRemove: favorites[index].id == null
                              ? null
                              : () => _remove(favorites[index].id!),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteProductEntry extends StatelessWidget {
  final int index;
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _FavoriteProductEntry({
    required this.index,
    required this.product,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final sequence = (index + 1).toString().padLeft(2, '0');
    final hasImage =
        product.coverImageUrl != null &&
        product.coverImageUrl!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                sequence,
                style: const TextStyle(
                  fontFamily: AppTheme.fontEditorial,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.softRose,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 1, color: AppTheme.divider)),
              const SizedBox(width: 12),
              Text(
                'FAVORITE',
                style: TextStyle(
                  fontFamily: AppTheme.fontTechnical,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.1,
                  color: AppTheme.mutedText,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1.42,
                  child: hasImage
                      ? AppwriteImage(
                          imageSource: product.coverImageUrl,
                          bucketId: AppwriteConfig.designFilesBucketId,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.zero,
                        )
                      : Container(
                          color: AppTheme.imagePlaceholder,
                          child: const Icon(
                            Icons.image_outlined,
                            color: AppTheme.mutedIvory,
                            size: 34,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontArabic,
                          color: AppTheme.warmIvory,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontTechnical,
                        color: AppTheme.softRose,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppTheme.softRose,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontTechnical,
                        color: AppTheme.mutedIvory,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'عرض التصميم',
                      style: TextStyle(
                        fontFamily: AppTheme.fontArabic,
                        color: AppTheme.softRose.withValues(alpha: 0.86),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: AppTheme.divider)),
              const SizedBox(width: 14),
              IconButton(
                tooltip: 'إزالة من المفضلة',
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(
                  Icons.favorite_rounded,
                  color: AppTheme.softRose.withValues(alpha: 0.82),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnavailableFavoriteEntry extends StatelessWidget {
  final Favorite favorite;
  final VoidCallback? onRemove;

  const _UnavailableFavoriteEntry({
    required this.favorite,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'UNAVAILABLE',
                style: TextStyle(
                  fontFamily: AppTheme.fontTechnical,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.1,
                  color: AppTheme.unavailableRose,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 1, color: AppTheme.divider)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'التصميم غير متاح حاليًا',
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: AppTheme.fontArabic,
              color: AppTheme.warmIvory,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            favorite.productId,
            style: const TextStyle(
              fontFamily: AppTheme.fontTechnical,
              color: AppTheme.secondaryText,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: AppTheme.divider)),
              const SizedBox(width: 14),
              IconButton(
                tooltip: 'إزالة من المفضلة',
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.unavailableRose,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductLoadingEntry extends StatelessWidget {
  const _ProductLoadingEntry();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 42),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 30, height: 1, color: AppTheme.divider),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 1, color: AppTheme.divider)),
            ],
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.42,
            child: Container(
              color: AppTheme.secondarySurface,
              alignment: Alignment.center,
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: AppTheme.roseBurgundy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesLoadingState extends StatelessWidget {
  const _FavoritesLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'FAVORITES',
            style: TextStyle(
              fontFamily: AppTheme.fontTechnical,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
              color: AppTheme.softRose,
            ),
          ),
          const SizedBox(height: 16),
          Container(width: 54, height: 1, color: AppTheme.divider),
          const SizedBox(height: 16),
          const Text(
            'جاري تحميل المفضلة',
            style: TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.mutedIvory,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  const _EmptyFavoritesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'FAVORITES',
              style: TextStyle(
                fontFamily: AppTheme.fontTechnical,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: AppTheme.softRose.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'لا توجد تصاميم في المفضلة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.warmIvory,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'أضف التصاميم التي تعجبك هنا للعودة إليها لاحقًا.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.secondaryText,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppTheme.unavailableRose,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.warmIvory,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: EditorialButton(
                onPressed: onRetry,
                label: 'إعادة المحاولة',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
