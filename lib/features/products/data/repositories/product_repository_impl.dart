import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource dataSource;

  ProductRepositoryImpl({required this.dataSource});

  @override
  Future<List<Product>> getProducts({
    int limit = 20,
    int offset = 0,
    String? categoryId,
  }) {
    return dataSource.getProducts(
      limit: limit,
      offset: offset,
      categoryId: categoryId,
    );
  }

  @override
  Future<Product?> getProductById(String id) {
    return dataSource.getProductById(id);
  }

  @override
  Future<List<Product>> getProductsByDesigner(String designerId) {
    return dataSource.getProductsByDesigner(designerId);
  }

  @override
  Future<List<Product>> searchProducts(String query) {
    return dataSource.searchProducts(query);
  }

  @override
  Future<Product> createProduct(Product product) {
    return dataSource.createProduct(product);
  }

  @override
  Future<Product> updateProduct(Product product) {
    return dataSource.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(String id) {
    return dataSource.deleteProduct(id);
  }
}
