import 'package:flutter/material.dart';

import 'package:trace_raffine/core/motion/maison_motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';
import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import '../products/products_screen.dart';
import 'domain/entities/category.dart';
import 'presentation/providers/category_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryRepository = ref.watch(categoryRepositoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: MaisonAppBar(title: 'التصنيفات'),
      body: FutureBuilder<List<Category>>(
        future: categoryRepository.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد تصنيفات',
                style: TextStyle(
                  fontFamily: AppTheme.fontArabic,
                  color: AppTheme.warmIvory,
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == 0) {
                      return const _CategoryEditorialHeader();
                    }

                    final category = categories[index - 1];

                    return _CategoryEditorialEntry(
                      category: category,
                      index: index - 1,
                    );
                  }, childCount: categories.length + 1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryEditorialHeader extends StatelessWidget {
  const _CategoryEditorialHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'عوالم التصميم',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: AppTheme.warmIvory,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'TRACÉ RAFFINÉ',
            style: TextStyle(
              fontFamily: AppTheme.fontEditorial,
              fontSize: 34,
              fontWeight: FontWeight.w500,
              height: 0.95,
              letterSpacing: 1.2,
              color: AppTheme.warmIvory,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 0.6,
            color: AppTheme.warmIvory.withValues(alpha: 0.30),
          ),
        ],
      ),
    );
  }
}

class _CategoryEditorialEntry extends StatefulWidget {
  const _CategoryEditorialEntry({required this.category, required this.index});

  final Category category;
  final int index;

  @override
  State<_CategoryEditorialEntry> createState() =>
      _CategoryEditorialEntryState();
}

class _CategoryEditorialEntryState extends State<_CategoryEditorialEntry> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final sequence = (widget.index + 1).toString().padLeft(2, '0');
    final horizontalPadding = context.responsiveHorizontalPadding;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: horizontalPadding),
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        onEnter: (_) {
          if (mounted) {
            setState(() => _hovered = true);
          }
        },
        onExit: (_) {
          if (mounted) {
            setState(() => _hovered = false);
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductsScreen(
                  categoryId: widget.category.id,
                  categoryTitle: widget.category.name,
                ),
              ),
            );
          },
          child: AnimatedContainer(
            duration: MaisonMotion.editorialInteraction,
            curve: MaisonMotion.easeOut,
            transform: Matrix4.translationValues(
              _hovered ? 8 : 0,
              _hovered ? -1 : 0,
              0,
            ),
            padding: const EdgeInsetsDirectional.symmetric(vertical: 13),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.warmIvory.withValues(
                    alpha: _hovered ? 0.38 : 0.16,
                  ),
                  width: 0.6,
                ),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedDefaultTextStyle(
                  duration: MaisonMotion.editorialInteraction,
                  curve: MaisonMotion.easeOut,
                  style: TextStyle(
                    fontFamily: AppTheme.fontEditorial,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    color: AppTheme.softRose.withValues(
                      alpha: _hovered ? 1 : 0.72,
                    ),
                  ),
                  child: Text(sequence),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: MaisonMotion.editorialInteraction,
                    curve: MaisonMotion.easeOut,
                    style: TextStyle(
                      fontFamily: AppTheme.fontArabic,
                      fontSize: 18,
                      fontWeight: _hovered ? FontWeight.w700 : FontWeight.w600,
                      height: 1.35,
                      color: AppTheme.warmIvory.withValues(
                        alpha: _hovered ? 1 : 0.88,
                      ),
                    ),
                    child: Text(
                      widget.category.name,
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                AnimatedScale(
                  scale: _hovered ? 1.12 : 1,
                  duration: MaisonMotion.editorialInteraction,
                  curve: MaisonMotion.easeOut,
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 15,
                    color: AppTheme.softRose.withValues(
                      alpha: _hovered ? 1 : 0.65,
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
