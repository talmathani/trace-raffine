import 'domain/entities/product.dart';
import 'presentation/controllers/product_list_controller.dart';
import 'product_details_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_raffine/core/appwrite/appwrite_config.dart';
import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/motion/maison_motion.dart';
import 'package:trace_raffine/core/ui/appwrite_image.dart';
import 'package:trace_raffine/core/ui/editorial_button.dart';
import 'package:trace_raffine/core/ui/maison_back_button.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  final String? categoryTitle;

  const ProductsScreen({super.key, this.categoryId, this.categoryTitle});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productListControllerProvider.notifier)
          .loadProducts(categoryId: widget.categoryId, sortBy: _sortBy);
    });
  }

  String _sortLabel(String value) {
    switch (value) {
      case 'price_high':
        return 'السعر: من الأعلى';
      case 'price_low':
        return 'السعر: من الأقل';
      default:
        return 'الأحدث';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListControllerProvider);
    final title = widget.categoryTitle?.trim().isNotEmpty == true
        ? widget.categoryTitle!.trim()
        : 'المنتجات';

    final isCompact = context.isCompact;
    final isMedium = context.isMedium;
    final pagePadding = context.responsiveHorizontalPadding;
    final headerTop = isCompact
        ? 14.0
        : isMedium
        ? 18.0
        : 22.0;
    final headerBottom = isCompact
        ? 6.0
        : isMedium
        ? 8.0
        : 10.0;
    final headerGap = isCompact
        ? 12.0
        : isMedium
        ? 18.0
        : 24.0;
    final brandSize = isCompact
        ? 10.0
        : isMedium
        ? 11.0
        : 12.0;
    final titleSize = isCompact
        ? 23.0
        : isMedium
        ? 28.0
        : 32.0;
    final metaSize = isCompact
        ? 10.0
        : isMedium
        ? 11.0
        : 12.0;
    final accentWidth = isCompact
        ? 36.0
        : isMedium
        ? 46.0
        : 60.0;
    final accentGap = isCompact
        ? 8.0
        : isMedium
        ? 10.0
        : 12.0;
    final dividerTop = isCompact
        ? 8.0
        : isMedium
        ? 10.0
        : 12.0;

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.paddingOf(context).top,
          right: MediaQuery.paddingOf(context).right,
          bottom: MediaQuery.paddingOf(context).bottom,
          left: MediaQuery.paddingOf(context).left,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.responsiveContentMaxWidth,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    pagePadding,
                    headerTop,
                    pagePadding,
                    headerBottom,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MaisonBackButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      SizedBox(width: headerGap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'TRACÉ RAFFINÉ',
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                color: AppTheme.warmIvory,
                                fontSize: brandSize,
                                letterSpacing: 3.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: AppTheme.editorialIvory,
                                fontSize: titleSize,
                                height: 1.0,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppTheme.fontArabic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pagePadding),
                  child: Row(
                    children: [
                      Container(
                        width: accentWidth,
                        height: 1,
                        color: AppTheme.richBurgundy,
                      ),
                      SizedBox(width: accentGap),
                      Text(
                        '${state.products.length.toString().padLeft(2, '0')} تصاميم',
                        style: TextStyle(
                          color: AppTheme.mutedText,
                          fontSize: metaSize,
                          letterSpacing: 1.0,
                          fontFamily: AppTheme.fontArabic,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        initialValue: _sortBy,
                        color: AppTheme.burgundyBlack,
                        onSelected: (value) {
                          setState(() => _sortBy = value);
                          ref
                              .read(productListControllerProvider.notifier)
                              .loadProducts(
                                categoryId: widget.categoryId,
                                sortBy: value,
                              );
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'newest',
                            child: Text('الأحدث'),
                          ),
                          const PopupMenuItem(
                            value: 'price_high',
                            child: Text('السعر: من الأعلى'),
                          ),
                          const PopupMenuItem(
                            value: 'price_low',
                            child: Text('السعر: من الأقل'),
                          ),
                        ],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _sortLabel(_sortBy),
                              style: TextStyle(
                                color: AppTheme.mutedText,
                                fontSize: 11,
                                fontFamily: AppTheme.fontArabic,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.productAccent,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    pagePadding,
                    dividerTop,
                    pagePadding,
                    0,
                  ),
                  child: Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppTheme.divider,
                  ),
                ),
                const Expanded(child: ProductsGrid()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductsGrid extends ConsumerWidget {
  const ProductsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productListControllerProvider);

    if (state.isLoading && state.products.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 1.2,
            color: AppTheme.softRose,
          ),
        ),
      );
    }

    if (state.error != null && state.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'تعذر تحميل المجموعة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.warmIvory,
                  fontSize: 20,
                  fontFamily: AppTheme.fontArabic,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.mutedText,
                  fontSize: 12,
                  fontFamily: AppTheme.fontArabic,
                ),
              ),
              const SizedBox(height: 20),
              EditorialButton(
                onPressed: () => ref
                    .read(productListControllerProvider.notifier)
                    .loadProducts(),
                label: 'إعادة المحاولة',
                variant: EditorialButtonVariant.secondary,
                compact: true,
              ),
            ],
          ),
        ),
      );
    }

    if (state.products.isEmpty) {
      return const Center(
        child: Text(
          'لم يتم العثور على تصاميم',
          style: TextStyle(
            color: AppTheme.mutedText,
            fontSize: 14,
            fontFamily: AppTheme.fontArabic,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenClass = context.screenClass;

        final columns = switch (screenClass) {
          AppScreenClass.compact => 2,
          AppScreenClass.medium => 2,
          AppScreenClass.expanded => 3,
          AppScreenClass.large => 4,
        };

        final horizontalPadding = context.responsiveHorizontalPadding;

        final spacing = switch (screenClass) {
          AppScreenClass.compact => 12.0,
          AppScreenClass.medium => 16.0,
          AppScreenClass.expanded => 22.0,
          AppScreenClass.large => 22.0,
        };

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            22,
            horizontalPadding,
            40,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 0.67,
            crossAxisSpacing: spacing,
            mainAxisSpacing: 30,
          ),
          itemCount: state.products.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.products.length) {
              return const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.2,
                    color: AppTheme.softRose,
                  ),
                ),
              );
            }

            return ProductCard(product: state.products[index]);
          },
        );
      },
    );
  }
}

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hovered = false;

  void _openDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: widget.product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final hasImage =
        product.coverImageUrl != null &&
        product.coverImageUrl!.trim().isNotEmpty;

    final isCompact = context.isCompact;
    final isMedium = context.isMedium;

    final overlayInset = isCompact
        ? 10.0
        : isMedium
        ? 12.0
        : 15.0;
    final titleSize = isCompact
        ? 14.0
        : isMedium
        ? 15.0
        : 16.0;
    final priceSize = isCompact
        ? 13.0
        : isMedium
        ? 14.0
        : 15.0;
    final arrowSize = isCompact
        ? 30.0
        : isMedium
        ? 32.0
        : 36.0;
    final bottomInset = isCompact
        ? 10.0
        : isMedium
        ? 12.0
        : 14.0;
    final titleGap = isCompact ? 4.0 : 5.0;
    final priceGap = isCompact ? 8.0 : 12.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap ?? () => _openDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AnimatedScale(
                scale: _hovered ? 1.012 : 1.0,
                duration: AppTheme.editorialFluid,
                curve: MaisonMotion.easeOut,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRect(
                      child: AnimatedScale(
                        scale: _hovered ? 1.035 : 1.0,
                        duration: const Duration(milliseconds: 720),
                        curve: MaisonMotion.easeOut,
                        child: hasImage
                            ? AppwriteImage(
                                imageSource: product.coverImageUrl,
                                bucketId: AppwriteConfig.designFilesBucketId,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorWidget: _ImageFallback(
                                  icon: Icons.image_not_supported_outlined,
                                ),
                              )
                            : const _ImageFallback(icon: Icons.image_outlined),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(
                              alpha: _hovered ? 0.08 : 0.0,
                            ),
                            Colors.black.withValues(
                              alpha: _hovered ? 0.72 : 0.30,
                            ),
                          ],
                          stops: const [0.42, 0.62, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      top: overlayInset,
                      left: 12,
                      child: _EditionMark(
                        number: product.id ?? '${product.hashCode}',
                      ),
                    ),
                    Positioned(
                      top: overlayInset,
                      right: 12,
                      child: AnimatedOpacity(
                        opacity: _hovered ? 1 : 0.72,
                        duration: AppTheme.editorialFast,
                        child: Container(
                          width: arrowSize,
                          height: arrowSize,
                          decoration: BoxDecoration(
                            color: AppTheme.obsidian,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.warmIvory.withValues(alpha: 0.35),
                              width: 0.6,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_outward_rounded,
                            color: AppTheme.editorialIvory,
                            size: isCompact
                                ? 14
                                : isMedium
                                ? 15
                                : 16,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 15,
                      right: 15,
                      bottom: bottomInset,
                      child: AnimatedOpacity(
                        opacity: _hovered ? 1 : 0,
                        duration: AppTheme.editorialReveal,
                        child: const _ViewLabel(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.editorialIvory,
                          fontSize: titleSize,
                          height: 1.15,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppTheme.fontArabic,
                        ),
                      ),
                      SizedBox(height: titleGap),
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 1,
                            color: AppTheme.richBurgundy,
                          ),
                          SizedBox(width: 7),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: priceGap),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    color: AppTheme.productAccent,
                    fontSize: priceSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
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

class _EditionMark extends StatelessWidget {
  final String number;

  const _EditionMark({required this.number});

  @override
  Widget build(BuildContext context) {
    final compact = number.length > 5 ? number.substring(0, 5) : number;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.obsidian.withValues(alpha: 0.68),
        border: Border.all(
          color: AppTheme.warmIvory.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Text(
        '#$compact',
        textDirection: TextDirection.ltr,
        style: TextStyle(
          color: AppTheme.mutedIvory,
          fontSize: 8,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _ViewLabel extends StatelessWidget {
  const _ViewLabel();

  @override
  Widget build(BuildContext context) {
    return EditorialSilkSweep(
      width: double.infinity,
      height: 38,
      accent: AppTheme.richBurgundy,
      child: Text(
        'عرض التصميم',
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppTheme.warmIvory,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.25,
          letterSpacing: 0.15,
          fontFamily: AppTheme.fontArabic,
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final IconData icon;

  const _ImageFallback({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.burgundyBlack,
      alignment: Alignment.center,
      child: Icon(icon, color: AppTheme.productAccent, size: 38),
    );
  }
}
