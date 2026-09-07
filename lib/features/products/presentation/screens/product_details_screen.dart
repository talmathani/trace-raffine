import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../favorites/presentation/providers/favorite_providers.dart';
import '../../../../core/auth/current_user_service.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends ConsumerState<ProductDetailsScreen> {
  bool _busy = false;
  bool _isFavorite = false;
  bool _favoriteLoaded = false;

  Future<void> _loadFavoriteState() async {
    if (_favoriteLoaded) return;

    final userId = await CurrentUserService.userId;
    if (userId == null || !mounted) return;

    try {
      final favoriteRepository = ref.read(favoriteRepositoryProvider);
      final value = await favoriteRepository.isFavorite(
        userId,
        widget.product.id!,
      );

      if (mounted) {
        setState(() {
          _isFavorite = value;
          _favoriteLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _favoriteLoaded = true);
      }
    }
  }

  Future<void> _addToCart() async {
    if (_busy) return;

    final productId = widget.product.id;
    if (productId == null || productId.isEmpty) {
      _showMessage('هذا التصميم لا يملك معرفًا صالحًا.');
      return;
    }

    final userId = await CurrentUserService.userId;
    if (userId == null) {
      _showMessage('يجب تسجيل الدخول أولًا لإضافة التصميم إلى السلة.');
      return;
    }

    setState(() => _busy = true);

    try {
      final repository = ref.read(cartRepositoryProvider);
      final List<CartItem> items = await repository.getCartItems(userId);
      final existing = items.where(
        (item) => item.productId == productId,
      );

      if (existing.isNotEmpty && existing.first.id != null) {
        await repository.updateQuantity(
          existing.first.id!,
          existing.first.quantity + 1,
        );
      } else {
        await repository.addToCart(userId, productId);
      }

      if (mounted) {
        _showMessage('تمت إضافة التصميم إلى السلة.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('تعذر إضافة التصميم إلى السلة: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_busy) return;

    final productId = widget.product.id;
    if (productId == null || productId.isEmpty) {
      _showMessage('هذا التصميم لا يملك معرفًا صالحًا.');
      return;
    }

    final userId = await CurrentUserService.userId;
    if (userId == null) {
      _showMessage('يجب تسجيل الدخول أولًا لإدارة المفضلة.');
      return;
    }

    setState(() => _busy = true);

    try {
      final repository = ref.read(favoriteRepositoryProvider);

      if (_isFavorite) {
        final favorites = await repository.getFavorites(userId);
        final match = favorites.where(
          (item) => item.productId == productId,
        );

        if (match.isNotEmpty && match.first.id != null) {
          await repository.removeFavorite(match.first.id!);
        }

        if (mounted) setState(() => _isFavorite = false);
      } else {
        await repository.addFavorite(userId, productId);

        if (mounted) setState(() => _isFavorite = true);
      }

      if (mounted) {
        _showMessage(
          _isFavorite
              ? 'تمت إضافة التصميم إلى المفضلة.'
              : 'تمت إزالة التصميم من المفضلة.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage('تعذر تحديث المفضلة: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    _loadFavoriteState();

    final product = widget.product;

    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.coverImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  product.coverImageUrl!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 300,
                    width: double.infinity,
                    alignment: Alignment.center,
                    color: const Color(0xFF722F37),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              product.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC9A227),
              ),
            ),
            const SizedBox(height: 16),
            if (product.description != null)
              Text(
                product.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _addToCart,
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Add to Cart'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _toggleFavorite,
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                    label: const Text('Favorite'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


