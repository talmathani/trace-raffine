import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    super.id,
    required super.designerId,
    required super.title,
    super.description,
    super.categoryId,
    required super.price,
    super.currency,
    super.status,
    super.coverImageUrl,
    super.salesCount,
    super.rating,
    super.reviewCount,
    super.createdAt,
    super.updatedAt,
    super.publishedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['\$id'],
      designerId: json['designer_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      categoryId: json['category_id'],
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'],
      status: ProductStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProductStatus.draft,
      ),
      coverImageUrl: json['cover_image_url'],
      salesCount: json['sales_count'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'])
          : null,
    );
  }
}
