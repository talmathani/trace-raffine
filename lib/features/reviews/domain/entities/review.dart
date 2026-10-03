class Review {
  final String? id;
  final String userId;
  final String productId;
  final int rating;
  final String? reviewText;
  final DateTime? createdAt;

  const Review({
    this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    this.reviewText,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'product_id': productId,
      'rating': rating,
      'review_text': reviewText,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['\$id'],
      userId: json['user_id'] ?? '',
      productId: json['product_id'] ?? '',
      rating: json['rating'] ?? 0,
      reviewText: json['review_text'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
