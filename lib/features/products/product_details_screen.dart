import 'package:flutter/material.dart';
import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/ui/editorial_button.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/motion/maison_motion.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'domain/entities/product.dart';
import '../favorites/presentation/providers/favorite_providers.dart';
import '../cart/presentation/providers/cart_providers.dart';
import 'package:trace_raffine/core/appwrite/appwrite_config.dart';
import 'package:trace_raffine/core/auth/current_user_service.dart';
import 'package:trace_raffine/core/ui/appwrite_image.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  bool _busy = false;
  bool _isFavorite = false;
  bool _favoriteLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    if (_favoriteLoaded) return;

    final productId = widget.product.id;
    if (productId == null || productId.isEmpty) {
      if (mounted) {
        setState(() => _favoriteLoaded = true);
      }
      return;
    }

    final userId = await CurrentUserService.userId;
    if (userId == null || !mounted) return;

    try {
      final repository = ref.read(favoriteRepositoryProvider);
      final value = await repository.isFavorite(userId, productId);

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

      await repository.addToCart(userId, productId, quantity: 1);

      if (mounted) {
        _showMessage('تمت إضافة التصميم إلى السلة.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('تعذر إضافة التصميم إلى السلة: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
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
        final matches = favorites.where((item) => item.productId == productId);

        if (matches.isNotEmpty && matches.first.id != null) {
          await repository.removeFavorite(matches.first.id!);
        }

        if (mounted) {
          setState(() => _isFavorite = false);
        }

        if (mounted) {
          _showMessage('تمت إزالة التصميم من المفضلة.');
        }
      } else {
        await repository.addFavorite(userId, productId);

        if (mounted) {
          setState(() => _isFavorite = true);
        }

        if (mounted) {
          _showMessage('تمت إضافة التصميم إلى المفضلة.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('تعذر تحديث المفضلة: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openImageFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: const MaisonAppBar(title: 'عرض التصميم'),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: AppwriteImage(
                    imageSource: widget.product.coverImageUrl,
                    bucketId: AppwriteConfig.designFilesBucketId,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 22 + MediaQuery.paddingOf(context).left,
                    top: 18 + MediaQuery.paddingOf(context).top,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: MaisonMotion.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value * 0.78,
                          child: Transform.translate(
                            offset: Offset(-4 * (1 - value), 0),
                            child: child,
                          ),
                        );
                      },
                      child: const Text(
                        'TRACÉ RAFFINÉ',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: AppTheme.fontEditorial,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.2,
                          color: AppTheme.warmIvory,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final screenClass = context.screenClass;
    final isCompact = context.isCompact;
    final isMedium = context.isMedium;
    final isWide = context.isExpanded || context.isLarge;

    final pagePadding = context.responsiveHorizontalPadding;

    final imageHeight = switch (screenClass) {
      AppScreenClass.compact => 300.0,
      AppScreenClass.medium => 380.0,
      AppScreenClass.expanded => 500.0,
      AppScreenClass.large => 560.0,
    };

    final contentGap = switch (screenClass) {
      AppScreenClass.compact => 18.0,
      AppScreenClass.medium => 24.0,
      AppScreenClass.expanded => 34.0,
      AppScreenClass.large => 40.0,
    };

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          maxLines: isCompact ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: isCompact
                ? 26
                : isMedium
                ? 30
                : 34,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontFamily: AppTheme.fontArabic,
            fontSize: isCompact
                ? 22
                : isMedium
                ? 25
                : 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.productAccent,
          ),
        ),
        const SizedBox(height: 18),
        if (product.description != null &&
            product.description!.trim().isNotEmpty)
          Text(
            product.description!,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.75,
              fontSize: isCompact
                  ? 14
                  : isMedium
                  ? 15
                  : 16,
            ),
          ),
        const SizedBox(height: 28),
        if (isWide)
          Row(
            children: [
              Expanded(
                child: EditorialButton(
                  onPressed: _busy ? null : _addToCart,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: 'إضافة إلى السلة',
                  variant: EditorialButtonVariant.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: EditorialButton(
                  onPressed: _busy ? null : _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: 'المفضلة',
                  variant: EditorialButtonVariant.secondary,
                ),
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditorialButton(
                onPressed: _busy ? null : _addToCart,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: 'إضافة إلى السلة',
                variant: EditorialButtonVariant.primary,
              ),
              const SizedBox(height: 12),
              EditorialButton(
                onPressed: _busy ? null : _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                label: 'المفضلة',
                variant: EditorialButtonVariant.secondary,
              ),
            ],
          ),
      ],
    );

    final imageSection = SizedBox(
      width: double.infinity,
      height: imageHeight,
      child:
          product.coverImageUrl != null &&
              product.coverImageUrl!.trim().isNotEmpty
          ? GestureDetector(
              onTap: _openImageFullscreen,
              child: AppwriteImage(
                imageSource: product.coverImageUrl,
                bucketId: AppwriteConfig.designFilesBucketId,
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(16),
                errorWidget: Container(
                  height: imageHeight,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.imagePlaceholder,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: AppTheme.warmIvory,
                    size: 56,
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );

    final content = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: imageSection),
              SizedBox(width: contentGap),
              Expanded(flex: 5, child: details),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              imageSection,
              SizedBox(height: contentGap),
              details,
            ],
          );

    return Scaffold(
      appBar: MaisonAppBar(title: product.title),
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top,
          right: MediaQuery.paddingOf(context).right,
          bottom: MediaQuery.paddingOf(context).bottom,
          left: MediaQuery.paddingOf(context).left,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: pagePadding,
            vertical: isCompact ? 16 : 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
