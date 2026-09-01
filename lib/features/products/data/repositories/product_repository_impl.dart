import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource dataSource;

  ProductRepositoryImpl(this.dataSource);

  @override
  Future<List<Product>> getProducts({int limit = 20, int offset = 0}) async {
    final models = await dataSource.getProducts(limit: limit, offset: offset);
    return models.cast<Product>();
  }

  @override
  Future<Product?> getProductById(String id) async {
    final model = await dataSource.getProductById(id);
    return model;
  }

  @override
  Future<List<Product>> getProductsByDesigner(String designerId) async {
    final models = await dataSource.getProductsByDesigner(designerId);
    return models.cast<Product>();
  }

  @override
  Future<Product> createProduct(Product product) async {
    final model = ProductModel(
      id: product.id,
      designerId: product.designerId,
      title: product.title,
      description: product.description,
      categoryId: product.categoryId,
      price: product.price,
      currency: product.currency,
      status: product.status,
      coverImageUrl: product.coverImageUrl,
      fileKey: product.fileKey,
      salesCount: product.salesCount,
      rating: product.rating,
      reviewCount: product.reviewCount,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      publishedAt: product.publishedAt,
    );
    return dataSource.createProduct(model);
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final model = ProductModel(
      id: product.id,
      designerId: product.designerId,
      title: product.title,
      description: product.description,
      categoryId: product.categoryId,
      price: product.price,
      currency: product.currency,
      status: product.status,
      coverImageUrl: product.coverImageUrl,
      fileKey: product.fileKey,
      salesCount: product.salesCount,
      rating: product.rating,
      reviewCount: product.reviewCount,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      publishedAt: product.publishedAt,
    );
    return dataSource.updateProduct(model);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await dataSource.deleteProduct(id);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final models = await dataSource.searchProducts(query);
    return models.cast<Product>();
  }
}
