import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    super.id,
    required super.userId,
    required super.productId,
    required super.rating,
    super.reviewText,
    super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
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
