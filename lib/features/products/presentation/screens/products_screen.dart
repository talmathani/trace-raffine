import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/product_list_controller.dart';
import '../widgets/products_grid.dart';

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
      ref.read(productListControllerProvider.notifier).loadProducts(
            categoryId: widget.categoryId,
            sortBy: _sortBy,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle ?? 'المنتجات'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _sortBy = value);
              ref.read(productListControllerProvider.notifier).loadProducts(
                    categoryId: widget.categoryId,
                    sortBy: value,
                  );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'newest', child: Text('الأحدث')),
              const PopupMenuItem(value: 'price_high', child: Text('السعر: من الأعلى')),
              const PopupMenuItem(value: 'price_low', child: Text('السعر: من الأقل')),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: const ProductsGrid(),
    );
  }
}
