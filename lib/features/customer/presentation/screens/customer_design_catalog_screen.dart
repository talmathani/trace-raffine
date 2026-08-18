import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/models/customer_design_model.dart';
import '../bloc/customer_design/customer_design_bloc.dart';

class CustomerDesignCatalogScreen extends StatefulWidget {
  const CustomerDesignCatalogScreen({super.key});

  @override
  State<CustomerDesignCatalogScreen> createState() =>
      _CustomerDesignCatalogScreenState();
}

class _CustomerDesignCatalogScreenState
    extends State<CustomerDesignCatalogScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.obsidian,
        appBar: AppBar(
          title: const Text(
            'التصاميم',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            _buildCategoryBar(),
            Expanded(
              child: BlocBuilder<CustomerDesignBloc, CustomerDesignState>(
                builder: (context, state) {
                  if (state is CustomerDesignInitial ||
                      state is CustomerDesignLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryBurgundy,
                      ),
                    );
                  }

                  if (state is CustomerDesignFailure) {
                    return _buildFailure(state.message);
                  }

                  if (state is CustomerDesignLoaded) {
                    if (state.designs.isEmpty) {
                      return _buildEmpty();
                    }

                    return RefreshIndicator(
                      color: AppTheme.primaryBurgundy,
                      backgroundColor: AppTheme.deepBurgundy,
                      onRefresh: () async {
                        context.read<CustomerDesignBloc>().add(
                          const CustomerDesignReloadRequested(),
                        );
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 360,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.82,
                            ),
                        itemCount: state.designs.length,
                        itemBuilder: (context, index) {
                          return _DesignCard(design: state.designs[index]);
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBar() {
    const categories = <String>[
      'الكل',
      'فساتين السهرة والهوت كوتور',
      'تصاميم الساري الهندي',
      'العبايات والبالطوهات',
      'الجلابيات والمخاور',
      'تصاميم موزعة',
      'تصاميم الحواشي',
      'الشعارات واللوغوهات',
    ];

    return SizedBox(
      height: 58,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = index == 0
              ? _selectedCategory == null
              : _selectedCategory == category;

          return ChoiceChip(
            label: Text(
              category,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppTheme.warmIvory : AppTheme.mutedIvory,
              ),
            ),
            selected: selected,
            onSelected: (_) {
              final value = index == 0 ? null : category;

              setState(() {
                _selectedCategory = value;
              });

              context.read<CustomerDesignBloc>().add(
                CustomerDesignCategoryChanged(category: value),
              );
            },
            selectedColor: AppTheme.deepBurgundy,
            backgroundColor: AppTheme.burgundyBlack,
            side: BorderSide(
              color: selected
                  ? AppTheme.primaryBurgundy.withValues(alpha: 0.55)
                  : AppTheme.divider,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFailure(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppTheme.softRose,
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppTheme.mutedIvory,
                height: 1.8,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                context.read<CustomerDesignBloc>().add(
                  const CustomerDesignReloadRequested(),
                );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome_outlined,
              size: 52,
              color: AppTheme.softRose,
            ),
            const SizedBox(height: 18),
            const Text(
              'لا توجد تصاميم متاحة حاليًا',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.warmIvory,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر هنا التصاميم المعتمدة من المصممين.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: AppTheme.mutedIvory,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesignCard extends StatelessWidget {
  const _DesignCard({required this.design});

  final CustomerDesignModel design;

  @override
  Widget build(BuildContext context) {
    final imageUrl = design.designImageUrl;

    return Card(
      color: AppTheme.burgundyBlack,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppTheme.divider),
      ),
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: imageUrl == null
                  ? Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [AppTheme.deepBurgundy, AppTheme.obsidian],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.design_services_rounded,
                          size: 48,
                          color: AppTheme.softRose,
                        ),
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.deepBurgundy,
                                AppTheme.obsidian,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 42,
                              color: AppTheme.softRose,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    design.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warmIvory,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    design.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppTheme.mutedIvory,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${design.price.toStringAsFixed(2)} USD',
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            fontFamily: 'CormorantGaramond',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBurgundy,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.deepBurgundy,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          design.fileExtension.toUpperCase(),
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.softRose,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
