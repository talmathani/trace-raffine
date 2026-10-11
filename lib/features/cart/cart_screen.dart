import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_raffine/core/appwrite/appwrite_config.dart';
import 'package:trace_raffine/core/auth/current_user_service.dart';
import 'package:trace_raffine/core/di/app_dependencies.dart';
import 'package:trace_raffine/core/motion/maison_motion.dart';
import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';
import 'package:trace_raffine/core/ui/appwrite_image.dart';
import 'package:trace_raffine/core/ui/editorial_button.dart';
import 'domain/entities/cart_item.dart';
import '../products/domain/entities/product.dart';
import '../products/product_details_screen.dart';
import '../orders/domain/entities/order.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  late Future<List<CartItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }

  Future<List<CartItem>> _loadItems() async {
    final userId = await CurrentUserService.userId;
    if (userId == null) return [];

    return ref.read(cartRepositoryProvider).getCartItems(userId);
  }

  Future<Product?> _loadProduct(String productId) {
    return ref.read(productRepositoryProvider).getProductById(productId);
  }

  Future<void> _refresh() async {
    setState(() {
      _itemsFuture = _loadItems();
    });
    await _itemsFuture;
  }

  Future<void> _updateQuantity(CartItem item, int quantity) async {
    if (item.id == null || quantity < 1) return;

    try {
      await ref.read(cartRepositoryProvider).updateQuantity(item.id!, quantity);

      if (!mounted) return;

      setState(() {
        _itemsFuture = _loadItems();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر تحديث الكمية: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _remove(String id) async {
    try {
      await ref.read(cartRepositoryProvider).removeFromCart(id);

      if (!mounted) return;

      setState(() {
        _itemsFuture = _loadItems();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف العنصر من السلة'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر حذف العنصر: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
    );
  }

  Future<void> _checkout(List<CartItem> items, List<Product?> products) async {
    final userId = await CurrentUserService.userId;
    if (userId == null || userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب تسجيل الدخول لإتمام الطلب.')),
        );
      }
      return;
    }

    final orderItems = <Map<String, dynamic>>[];
    for (var i = 0; i < items.length; i++) {
      final product = products[i];
      if (product == null || product.id == null || product.id!.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يوجد تصميم غير متاح في السلة.')),
        );
        return;
      }
      orderItems.add({
        'productId': product.id,
        'price': product.price,
        'quantity': items[i].quantity,
      });
    }

    try {
      final total = orderItems.fold<double>(
        0,
        (sum, item) =>
            sum + (item['price'] as double) * (item['quantity'] as int),
      );
      final order = await ref
          .read(orderRepositoryProvider)
          .createOrder(
            Order(userId: userId, totalAmount: total, currency: 'USD'),
            orderItems,
          );
      if (!mounted) return;
      setState(() => _itemsFuture = _loadItems());
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('تم إنشاء الطلب'),
          content: Text(
            'تم إنشاء طلبك وهو بانتظار إتمام الدفع${order.id == null ? '.' : ' — رقم الطلب: ${order.id!}'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذر إنشاء الطلب: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: MaisonAppBar(title: 'السلة'),
      body: FutureBuilder<List<CartItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _CartLoadingState();
          }

          if (snapshot.hasError) {
            return _CartErrorState(onRetry: _refresh);
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const _EmptyCartState();
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
                child: FutureBuilder<List<Product?>>(
                  future: Future.wait(
                    items.map((item) => _loadProduct(item.productId)),
                  ),
                  builder: (context, productsSnapshot) {
                    if (productsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          context.responsiveHorizontalPadding,
                          context.isCompact ? 16 : 22,
                          context.responsiveHorizontalPadding,
                          32,
                        ),
                        children: const [
                          _CartLoadingEntry(),
                          _CartLoadingEntry(),
                        ],
                      );
                    }

                    final products = productsSnapshot.data ?? [];
                    double total = 0;

                    for (var i = 0; i < items.length; i++) {
                      final product = i < products.length ? products[i] : null;
                      if (product != null) {
                        total += product.price * items[i].quantity;
                      }
                    }

                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        context.responsiveHorizontalPadding,
                        context.isCompact ? 16 : 22,
                        context.responsiveHorizontalPadding,
                        32,
                      ),
                      children: [
                        _CartHeader(itemCount: items.length),
                        const SizedBox(height: 18),
                        for (var i = 0; i < items.length; i++)
                          _CartEditorialEntry(
                            sequence: i + 1,
                            item: items[i],
                            product: i < products.length ? products[i] : null,
                            onTap: i < products.length && products[i] != null
                                ? () => _openProduct(products[i]!)
                                : null,
                            onIncrease: () => _updateQuantity(
                              items[i],
                              items[i].quantity + 1,
                            ),
                            onDecrease: items[i].quantity > 1
                                ? () => _updateQuantity(
                                    items[i],
                                    items[i].quantity - 1,
                                  )
                                : null,
                            onRemove: items[i].id == null
                                ? null
                                : () => _remove(items[i].id!),
                          ),
                        const SizedBox(height: 26),
                        _CartSummary(
                          total: total,
                          hasUnavailableProducts: products.any(
                            (product) => product == null,
                          ),
                          onCheckout: () => _checkout(items, products),
                        ),
                      ],
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

class _CartHeader extends StatelessWidget {
  final int itemCount;

  const _CartHeader({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    final label = itemCount == 1 ? 'عنصر' : 'عناصر';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Text(
            'محتويات السلة',
            style: TextStyle(
              fontFamily: AppTheme.fontArabic,
              color: AppTheme.warmIvory,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        Text(
          '$itemCount $label',
          style: const TextStyle(
            fontFamily: AppTheme.fontTechnical,
            color: AppTheme.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _CartEditorialEntry extends StatelessWidget {
  final int sequence;
  final CartItem item;
  final Product? product;
  final VoidCallback? onTap;
  final VoidCallback onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onRemove;

  const _CartEditorialEntry({
    required this.sequence,
    required this.item,
    required this.product,
    required this.onTap,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final title = product?.title ?? 'التصميم غير متاح';
    final price = product?.price ?? 0;
    final hasImage =
        product?.coverImageUrl != null &&
        product!.coverImageUrl!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sequence.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontEditorial,
                      color: AppTheme.softRose,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      height: 0.9,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'CART',
                    style: TextStyle(
                      fontFamily: AppTheme.fontTechnical,
                      color: AppTheme.mutedText,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const Spacer(),
                  if (product != null)
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontTechnical,
                        color: AppTheme.warmIvory,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.15,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 1.55,
                child: hasImage
                    ? AppwriteImage(
                        imageSource: product!.coverImageUrl,
                        bucketId: AppwriteConfig.designFilesBucketId,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(2),
                      )
                    : Container(
                        color: AppTheme.imagePlaceholder,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppTheme.mutedIvory,
                          size: 30,
                        ),
                      ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: AppTheme.fontArabic,
                  color: AppTheme.warmIvory,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Row(
          children: [
            const Text(
              'الكمية',
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            _QuantityControl(icon: Icons.remove_rounded, onPressed: onDecrease),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${item.quantity}',
                style: const TextStyle(
                  fontFamily: AppTheme.fontTechnical,
                  color: AppTheme.warmIvory,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _QuantityControl(icon: Icons.add_rounded, onPressed: onIncrease),
            const Spacer(),
            IconButton(
              tooltip: 'حذف',
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.unavailableRose,
                size: 21,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Divider(height: 1, thickness: 1, color: AppTheme.divider),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _QuantityControl extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityControl({required this.icon, required this.onPressed});

  @override
  State<_QuantityControl> createState() => _QuantityControlState();
}

class _QuantityControlState extends State<_QuantityControl> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedContainer(
        duration: MaisonMotion.editorialInteraction,
        curve: MaisonMotion.easeOut,
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.richBurgundy.withValues(alpha: _pressed ? 0.55 : 0.22)
              : AppTheme.secondarySurface.withValues(alpha: 0.18),
          border: Border.all(
            color: enabled
                ? AppTheme.roseBurgundy.withValues(
                    alpha: _pressed ? 0.65 : 0.28,
                  )
                : AppTheme.divider.withValues(alpha: 0.45),
          ),
          borderRadius: BorderRadius.circular(19),
        ),
        child: Icon(
          widget.icon,
          size: 17,
          color: enabled ? AppTheme.softRose : AppTheme.mutedText,
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double total;
  final bool hasUnavailableProducts;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.total,
    required this.hasUnavailableProducts,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 2),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'الإجمالي',
                  style: TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    color: AppTheme.warmIvory,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: AppTheme.fontTechnical,
                  color: AppTheme.softRose,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          if (hasUnavailableProducts) ...[
            const SizedBox(height: 10),
            const Text(
              'بعض العناصر غير متاحة حاليًا، لذلك لم تدخل في الإجمالي.',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.unavailableRose,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 18),
          EditorialButton(
            onPressed: hasUnavailableProducts || total <= 0 ? null : onCheckout,
            label: 'متابعة الشراء',
          ),
        ],
      ),
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondarySurface,
                border: Border.all(
                  color: AppTheme.roseBurgundy.withValues(alpha: 0.3333),
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppTheme.roseBurgundy,
                size: 42,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'السلة فارغة',
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.warmIvory,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أضف التصاميم التي تريد شراءها إلى السلة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.secondaryText,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartLoadingState extends StatelessWidget {
  const _CartLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.roseBurgundy),
    );
  }
}

class _CartLoadingEntry extends StatelessWidget {
  const _CartLoadingEntry();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Text(
                'CART',
                style: TextStyle(
                  fontFamily: AppTheme.fontTechnical,
                  color: AppTheme.mutedText,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.8,
                ),
              ),
              Spacer(),
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  color: AppTheme.roseBurgundy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1.55,
            child: ColoredBox(color: AppTheme.secondarySurface),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, thickness: 1, color: AppTheme.divider),
        ],
      ),
    );
  }
}

class _CartErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _CartErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppTheme.unavailableRose,
              size: 44,
            ),
            const SizedBox(height: 16),
            const Text(
              'تعذر تحميل السلة',
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.warmIvory,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            EditorialButton(onPressed: onRetry, label: 'إعادة المحاولة'),
          ],
        ),
      ),
    );
  }
}
