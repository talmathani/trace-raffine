enum ProductStatus {
  draft,
  pendingReview,
  published,
  unpublished,
  rejected,
  archived
}

class Product {
  final String? id;
  final String designerId;
  final String title;
  final String? description;
  final String? categoryId;
  final double price;
  final String? currency;
  final ProductStatus status;
  final String? coverImageUrl;
  final String? fileKey;
  final int salesCount;
  final double rating;
  final int reviewCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;

  const Product({
    this.id,
    required this.designerId,
    required this.title,
    this.description,
    this.categoryId,
    required this.price,
    this.currency,
    this.status = ProductStatus.draft,
    this.coverImageUrl,
    this.fileKey,
    this.salesCount = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
  });

  Product copyWith({
    String? id,
    String? designerId,
    String? title,
    String? description,
    String? categoryId,
    double? price,
    String? currency,
    ProductStatus? status,
    String? coverImageUrl,
    String? fileKey,
    int? salesCount,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
  }) {
    return Product(
      id: id ?? this.id,
      designerId: designerId ?? this.designerId,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      fileKey: fileKey ?? this.fileKey,
      salesCount: salesCount ?? this.salesCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'designer_id': designerId,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'price': price,
      'currency': currency,
      'status': status.name,
      'cover_image_url': coverImageUrl,
      'file_key': fileKey,
      'sales_count': salesCount,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['\$id'],
      designerId: json['designer_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      categoryId: json['category_id'],
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'],
      status: _parseStatus(json['status']),
      coverImageUrl: json['cover_image_url'],
      fileKey: json['file_key'],
      salesCount: json['sales_count'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      publishedAt: json['published_at'] != null ? DateTime.tryParse(json['published_at']) : null,
    );
  }

  static ProductStatus _parseStatus(String? value) {
    if (value == null) return ProductStatus.draft;
    return ProductStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProductStatus.draft,
    );
  }
}
