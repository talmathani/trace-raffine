import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/luxury_ui.dart';
import '../products/presentation/controllers/product_list_controller.dart';
import '../products/presentation/screens/products_screen.dart';
import '../products/presentation/widgets/product_card.dart';
import '../widgets/luxury_categories_header.dart';

class SharedHomeScreen extends ConsumerStatefulWidget {
  const SharedHomeScreen({super.key});

  @override
  ConsumerState<SharedHomeScreen> createState() => _SharedHomeScreenState();
}

class _SharedHomeScreenState extends ConsumerState<SharedHomeScreen> {

  static const List<HomeCategory> categories = [
    HomeCategory(
      title: 'فساتين السهرة والهوت كوتور',
      subtitle: 'Evening Couture Designs',
      icon: Icons.checkroom_rounded,
      categoryId: 'evening_couture',
    ),
    HomeCategory(
      title: 'تصاميم الساري الهندي',
      subtitle: 'Indian Saree Designs',
      icon: Icons.auto_awesome_rounded,
      categoryId: 'saree',
    ),
    HomeCategory(
      title: 'العبايات والبالطوهات',
      subtitle: 'Abayas & Coats',
      icon: Icons.layers_rounded,
      categoryId: 'abayas',
    ),
    HomeCategory(
      title: 'الجلابيات والمخاور',
      subtitle: 'Jalabiyas & Makhawer',
      icon: Icons.pattern_rounded,
      categoryId: 'jalabiyas',
    ),
    HomeCategory(
      title: 'تصاميم موزعة',
      subtitle: 'Distributed Designs',
      icon: Icons.scatter_plot_rounded,
      categoryId: 'distributed',
    ),
    HomeCategory(
      title: 'تصاميم الحواشي',
      subtitle: 'Border Designs',
      icon: Icons.border_style_rounded,
      categoryId: 'borders',
    ),
    HomeCategory(
      title: 'الشعارات واللوغوهات',
      subtitle: 'Logos & Symbols',
      icon: Icons.diamond_rounded,
      categoryId: 'logos',
    ),
    HomeCategory(
      title: 'جديد الأسبوع',
      subtitle: 'New This Week',
      icon: Icons.auto_awesome_mosaic_rounded,
      categoryId: 'new_week',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(productListControllerProvider.notifier).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1200
        ? 4
        : width >= 800
        ? 3
        : width >= 520
        ? 2
        : 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.obsidian,
        appBar: AppBar(title: const Text('الرئيسية')),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHero()),
            SliverToBoxAdapter(child: _buildNewsTicker()),
            const SliverToBoxAdapter(child: _PublishedDesignsSection()),
            const SliverToBoxAdapter(child: LuxuryCategoriesHeader(height: 82)),
            SliverToBoxAdapter(child: _buildSectionHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categories[index];
                  return _CategoryCard(
                    category: category,
                    index: index,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductsScreen(
                            categoryId: category.categoryId,
                            categoryTitle: category.title,
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: categories.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: columns == 1 ? 3.2 : 1.18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppTheme.deepBurgundy,
            AppTheme.burgundyBlack,
            AppTheme.obsidian,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.divider),
        boxShadow: [
          BoxShadow(
            color: AppTheme.obsidian.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 2,
                decoration: BoxDecoration(
                  color: AppTheme.softRose,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'DIGITAL EMBROIDERY',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.8,
                  color: AppTheme.softRose,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'TRACÉ RAFFINÉ',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: 34,
              fontWeight: FontWeight.w600,
              letterSpacing: 3.5,
              color: AppTheme.warmIvory,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'عالم الحِرفة الرقمية',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'اكتشف تصاميم التطريز الرقمي المختارة بعناية، واستكشف مجموعاتنا المتخصصة في مساحة واحدة.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              height: 1.8,
              color: AppTheme.mutedIvory,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const LuxuryBadge(
                label: 'تصاميم احترافية',
                icon: Icons.verified_rounded,
              ),
              const SizedBox(width: 8),
              LuxuryBadge(
                label: 'TR Collection',
                icon: Icons.auto_awesome_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTicker() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: const Row(
        children: [
          SizedBox(width: 14),
          LuxuryIcon(
            icon: Icons.campaign_outlined,
            size: 17,
            background: AppTheme.deepBurgundy,
            borderRadius: 9,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'اكتشف أحدث التصاميم والمجموعات الجديدة في TRACÉ RAFFINÉ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppTheme.mutedIvory,
              ),
            ),
          ),
          SizedBox(width: 14),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 30, 20, 16),
      child: LuxurySectionHeader(
        title: 'الأقسام',
        subtitle: 'استكشف مجموعات التطريز الرقمي',
        trailing: LuxuryIcon(
          icon: Icons.auto_awesome_rounded,
          size: 18,
          background: AppTheme.deepBurgundy,
          borderRadius: 10,
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.index,
    required this.onTap,
  });
  final HomeCategory category;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      onTap: onTap,
      hoverLift: true,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            _LuxuryCategoryIcon(icon: category.icon, index: index),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warmIvory,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.subtitle,
                    textDirection: TextDirection.ltr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 12,
                      color: AppTheme.softRose,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_left_rounded,
              color: AppTheme.mutedText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxuryCategoryIcon extends StatelessWidget {
  const _LuxuryCategoryIcon({required this.icon, required this.index});
  final IconData icon;
  final int index;

  @override
  Widget build(BuildContext context) {
    final opacity = 0.10 + ((index % 4) * 0.025);
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.softRose.withValues(alpha: opacity + 0.08),
            AppTheme.deepBurgundy,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softRose.withValues(alpha: 0.20)),
      ),
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0B5BE), Color(0xFFC98F9C), Color(0xFF8F5968)],
        ).createShader(bounds),
        child: Icon(icon, size: 28),
      ),
    );
  }
}

class _PublishedDesignsSection extends ConsumerWidget {
  const _PublishedDesignsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productListControllerProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LuxurySectionHeader(
            title: 'التصاميم المعروضة للبيع',
            subtitle: 'تصاميم منشورة ومتاحة للاقتناء',
            trailing: LuxuryIcon(
              icon: Icons.shopping_bag_outlined,
              size: 18,
              background: AppTheme.deepBurgundy,
              borderRadius: 10,
            ),
          ),
          const SizedBox(height: 14),
          if (state.isLoading && state.products.isEmpty)
            const SizedBox(
              height: 260,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.error != null && state.products.isEmpty)
            SizedBox(
              height: 120,
              child: Center(child: Text('تعذر تحميل التصاميم المعروضة.')),
            )
          else if (state.products.isEmpty)
            const SizedBox(
              height: 120,
              child: Center(child: Text('لا توجد تصاميم منشورة للبيع حاليًا.')),
            )
          else
            SizedBox(
              height: 290,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.products.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return SizedBox(
                    width: 220,
                    child: ProductCard(product: product, onTap: () {}),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class HomeCategory {
  const HomeCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.categoryId,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final String categoryId;
}

