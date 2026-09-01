import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_data_source.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewDataSource dataSource;

  ReviewRepositoryImpl(this.dataSource);

  @override
  Future<List<Review>> getReviews(String productId) async {
    final models = await dataSource.getReviews(productId);
    return models.cast<Review>();
  }

  @override
  Future<Review> addReview(Review review) async {
    final model = ReviewModel(
      id: review.id,
      userId: review.userId,
      productId: review.productId,
      rating: review.rating,
      reviewText: review.reviewText,
      createdAt: review.createdAt,
    );
    return dataSource.addReview(model);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await dataSource.deleteReview(reviewId);
  }
}
