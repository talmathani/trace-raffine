import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviews(String productId);
  Future<Review> addReview(Review review);
  Future<void> deleteReview(String reviewId);
}
