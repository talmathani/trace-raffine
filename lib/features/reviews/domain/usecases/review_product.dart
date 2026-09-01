import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../../../purchases/domain/repositories/purchase_repository.dart';

class ReviewProductUseCase {
  final ReviewRepository reviewRepository;
  final PurchaseRepository purchaseRepository;

  ReviewProductUseCase({
    required this.reviewRepository,
    required this.purchaseRepository,
  });

  Future<Review> call({
    required String userId,
    required String productId,
    required int rating,
    String? reviewText,
  }) async {
    final hasPurchased = await purchaseRepository.hasPurchased(userId, productId);
    if (!hasPurchased) {
      throw Exception('User has not purchased this product');
    }

    final review = Review(
      userId: userId,
      productId: productId,
      rating: rating,
      reviewText: reviewText,
    );

    return await reviewRepository.addReview(review);
  }
}
