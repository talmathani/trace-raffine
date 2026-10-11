import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../providers/product_providers.dart';

class ProductListState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final int offset;
  final bool hasMore;

  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.offset = 0,
    this.hasMore = true,
  });

  ProductListState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    int? offset,
    bool? hasMore,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ProductListController extends StateNotifier<ProductListState> {
  final ProductRepository repository;
  String? _categoryId;
  String _sortBy = 'newest';

  ProductListController(this.repository) : super(const ProductListState());

  Future<void> loadProducts({
    String? categoryId,
    String sortBy = 'newest',
  }) async {
    _categoryId = categoryId;
    _sortBy = sortBy;
    state = state.copyWith(
      isLoading: true,
      error: null,
      products: const [],
      offset: 0,
      hasMore: true,
    );
    try {
      final products = await repository.getProducts(
        limit: 20,
        offset: 0,
        categoryId: _categoryId,
      );

      _sort(products);

      state = state.copyWith(
        products: products,
        isLoading: false,
        offset: products.length,
        hasMore: products.length == 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _sort(List<Product> products) {
    products.sort((a, b) {
      switch (_sortBy) {
        case 'price_high':
          return b.price.compareTo(a.price);
        case 'price_low':
          return a.price.compareTo(b.price);
        case 'newest':
        default:
          return (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          );
      }
    });
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final products = await repository.getProducts(
        limit: 20,
        offset: state.offset,
        categoryId: _categoryId,
      );
      _sort(products);
      state = state.copyWith(
        products: [...state.products, ...products],
        isLoading: false,
        offset: state.offset + products.length,
        hasMore: products.length == 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await repository.searchProducts(query);
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final productListControllerProvider =
    StateNotifierProvider<ProductListController, ProductListState>((ref) {
      return ProductListController(ref.watch(productRepositoryProvider));
    });
