import 'package:flutter/material.dart';

import 'package:trace_raffine/core/motion/maison_motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trace_raffine/core/theme/app_theme.dart';
import '../products/products_screen.dart';

class SharedHomeScreen extends ConsumerStatefulWidget {
  const SharedHomeScreen({super.key});

  @override
  ConsumerState<SharedHomeScreen> createState() => _SharedHomeScreenState();
}

class _SharedHomeScreenState extends ConsumerState<SharedHomeScreen> {
  static const List<HomeCategory> categories = [
    HomeCategory(
      title: 'فساتين السهرة والهوت كوتور',
      subtitle: 'تصاميم السهرة الراقية',
      icon: Icons.checkroom_rounded,
      categoryId: 'evening_couture',
    ),
    HomeCategory(
      title: 'تصاميم الساري الهندي',
      subtitle: 'تصاميم الساري الهندي',
      icon: Icons.auto_awesome_rounded,
      categoryId: 'saree',
    ),
    HomeCategory(
      title: 'العبايات والبالطوهات',
      subtitle: 'العبايات والمعاطف',
      icon: Icons.layers_rounded,
      categoryId: 'abayas',
    ),
    HomeCategory(
      title: 'الجلابيات والمخاور',
      subtitle: 'الجلابيات والمخاوير',
      icon: Icons.pattern_rounded,
      categoryId: 'jalabiyas',
    ),
    HomeCategory(
      title: 'تصاميم موزعة',
      subtitle: 'التصاميم الموزعة',
      icon: Icons.scatter_plot_rounded,
      categoryId: 'distributed',
    ),
    HomeCategory(
      title: 'تصاميم الحواشي',
      subtitle: 'تصاميم الحواف',
      categoryId: 'borders',
      icon: Icons.border_style_rounded,
    ),
    HomeCategory(
      title: 'الشعارات واللوغوهات',
      subtitle: 'الشعارات واللوغوهات',
      categoryId: 'logos',
      icon: Icons.diamond_rounded,
    ),
    HomeCategory(
      title: 'جديد الأسبوع',
      subtitle: 'جديد هذا الأسبوع',
      categoryId: 'new_week',
      icon: Icons.auto_awesome_mosaic_rounded,
    ),
  ];

  // لا يوجد تحميل بيانات عند فتح الصفحة.
  // المنتجات تُطلب فقط عندما يختار المستخدم قسمًا فعليًا.
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.obsidian,
        body: _EditorialHero(
          categories: categories,
          onCategoryTap: (category) => _openCategory(context, category),
        ),
      ),
    );
  }

  void _openCategory(BuildContext context, HomeCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductsScreen(
          categoryId: category.categoryId,
          categoryTitle: category.title,
        ),
      ),
    );
  }
}

class _EditorialHero extends StatefulWidget {
  const _EditorialHero({required this.categories, required this.onCategoryTap});

  final List<HomeCategory> categories;
  final ValueChanged<HomeCategory> onCategoryTap;

  @override
  State<_EditorialHero> createState() => _EditorialHeroState();
}

class _EditorialHeroState extends State<_EditorialHero> {
  bool _entered = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _entered = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = MediaQuery.sizeOf(context).height;

        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1000;

        final brandSize = isMobile
            ? 14.0
            : isTablet
            ? 16.0
            : 19.0;

        return SizedBox(
          width: double.infinity,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _HeroPhotography(),

              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppTheme.obsidian.withValues(alpha: 0.84),
                          AppTheme.obsidian.withValues(alpha: 0.34),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.30, 0.68],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppTheme.obsidian.withValues(alpha: 0.70),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.42],
                      ),
                    ),
                  ),
                ),
              ),

              Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: isMobile
                        ? (24 - width * 0.10).clamp(16.0, double.infinity)
                        : isTablet
                        ? (46 - width * 0.10).clamp(16.0, double.infinity)
                        : width >= 1400
                        ? (86 - width * 0.10).clamp(24.0, double.infinity)
                        : (68 - width * 0.10).clamp(24.0, double.infinity),
                    top: height * 0.10,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile
                            ? width * 0.62
                            : isTablet
                            ? 390
                            : 430,
                      ),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 1100),
                        curve: MaisonMotion.easeOut,
                        opacity: _entered ? 1 : 0,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 1100),
                          curve: MaisonMotion.easeOut,
                          offset: _entered
                              ? Offset.zero
                              : const Offset(-0.035, 0),
                          child: _EditorialHeroContent(
                            isMobile: isMobile,
                            categories: widget.categories,
                            onCategoryTap: widget.onCategoryTap,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: isMobile ? 22 : 34,
                    right: isMobile
                        ? 18
                        : isTablet
                        ? 28
                        : 48,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 1300),
                      curve: MaisonMotion.easeOut,
                      opacity: _entered ? 0.88 : 0,
                      child: _RightBrandMark(
                        fontSize: brandSize,
                        compact: isMobile,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroPhotography extends StatelessWidget {
  const _HeroPhotography();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/IMG_4123.PNG',
      fit: BoxFit.cover,
      alignment: Alignment.centerRight,
      filterQuality: FilterQuality.high,
    );
  }
}

class _RightBrandMark extends StatelessWidget {
  const _RightBrandMark({required this.fontSize, required this.compact});

  final double fontSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      'TRACÉ RAFFINÉ',
      textDirection: TextDirection.ltr,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(
        fontFamily: AppTheme.fontEditorial,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: compact ? 0.7 : 1.2,
        color: AppTheme.warmIvory,
      ),
    );
  }
}

class _EditorialHeroContent extends StatelessWidget {
  const _EditorialHeroContent({
    required this.isMobile,
    required this.categories,
    required this.onCategoryTap,
  });

  final bool isMobile;
  final List<HomeCategory> categories;
  final ValueChanged<HomeCategory> onCategoryTap;

  static const List<String> _arabicLabels = <String>[
    'فساتين السهرة',
    'القوالب وفصوص الكرستال',
    'العبايات والبالطوهات',
    'الجلابيات والمخاوير',
    'التصاميم الموزعة',
    'تصاميم الحواشي',
    'الشعارات واللوغوهات',
    'جديد الأسبوع',
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final visibleCategories = categories.take(8).toList(growable: false);

    final indexWidth = width * 0.35;

    return SizedBox(
      width: indexWidth,
      child: ClipRect(
        child: _FashionIndexPanel(
          categories: visibleCategories,
          labels: _arabicLabels,
          isMobile: isMobile,
          onCategoryTap: onCategoryTap,
        ),
      ),
    );
  }
}

class _FashionIndexPanel extends StatefulWidget {
  const _FashionIndexPanel({
    required this.categories,
    required this.labels,
    required this.isMobile,
    required this.onCategoryTap,
  });

  final List<HomeCategory> categories;
  final List<String> labels;
  final bool isMobile;
  final ValueChanged<HomeCategory> onCategoryTap;

  @override
  State<_FashionIndexPanel> createState() => _FashionIndexPanelState();
}

class _FashionIndexPanelState extends State<_FashionIndexPanel> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final panelHeight = screenHeight * (widget.isMobile ? 0.72 : 0.78);
    final horizontalPadding = widget.isMobile ? 0.0 : 2.0;

    return SizedBox(
      height: panelHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'عوالم التصميم الراقية',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: widget.isMobile ? 15.0 : 19.0,
                fontWeight: FontWeight.w700,
                height: 1.15,
                color: AppTheme.warmIvory,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'ثمانية عوالم تجمع فساتين السهرة والساري والعبايات والجلابيات والزخارف والشعارات وأحدث التصاميم.',
              textDirection: TextDirection.rtl,
              maxLines: widget.isMobile ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: widget.isMobile ? 9.0 : AppTheme.arabicMetaSize,
                fontWeight: FontWeight.w400,
                height: 1.65,
                color: AppTheme.warmIvory.withValues(alpha: 0.66),
              ),
            ),
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              height: 0.6,
              color: AppTheme.warmIvory.withValues(alpha: 0.34),
            ),
            SizedBox(height: screenHeight * 0.10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(
                  widget.categories.length,
                  (index) => _FashionIndexEntry(
                    index: index,
                    editorialLabel: widget.labels[index],
                    category: widget.categories[index],
                    isMobile: widget.isMobile,
                    onTap: () => widget.onCategoryTap(widget.categories[index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FashionIndexEntry extends StatefulWidget {
  const _FashionIndexEntry({
    required this.index,
    required this.editorialLabel,
    required this.category,
    required this.isMobile,
    required this.onTap,
  });

  final int index;
  final String editorialLabel;
  final HomeCategory category;
  final bool isMobile;
  final VoidCallback onTap;

  @override
  State<_FashionIndexEntry> createState() => _FashionIndexEntryState();
}

class _FashionIndexEntryState extends State<_FashionIndexEntry> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final categoryFontSize = widget.isMobile ? 15.5 : 19.5;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (!widget.isMobile && mounted) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (!widget.isMobile && mounted) {
          setState(() => _hovered = false);
        }
      },
      child: Semantics(
        button: true,
        label: widget.category.title,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: MaisonMotion.editorialInteraction,
            curve: MaisonMotion.easeOut,
            transform: Matrix4.translationValues(
              _hovered ? 12.0 : 0.0,
              _hovered ? -1.0 : 0.0,
              0.0,
            ),
            padding: EdgeInsets.symmetric(
              vertical: widget.isMobile ? 5.0 : 6.5,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AnimatedScale(
                    scale: _hovered ? 1.07 : 1.0,
                    alignment: Alignment.centerLeft,
                    duration: MaisonMotion.editorialInteraction,
                    curve: MaisonMotion.easeOut,
                    child: AnimatedDefaultTextStyle(
                      duration: MaisonMotion.editorialInteraction,
                      curve: MaisonMotion.easeOut,
                      style: TextStyle(
                        fontFamily: AppTheme.fontArabic,
                        fontSize: categoryFontSize,
                        fontWeight: _hovered
                            ? FontWeight.w700
                            : FontWeight.w600,
                        height: 1.25,
                        color: AppTheme.warmIvory.withValues(
                          alpha: _hovered ? 1.0 : 0.88,
                        ),
                      ),
                      child: Text(
                        widget.editorialLabel,
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
