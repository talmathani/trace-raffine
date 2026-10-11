import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({
    int limit = 20,
    int offset = 0,
    String? categoryId,
  });
  Future<Product?> getProductById(String id);
  Future<List<Product>> getProductsByDesigner(String designerId);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<List<Product>> searchProducts(String query);
}
