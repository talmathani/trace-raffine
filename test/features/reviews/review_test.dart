import 'package:flutter_test/flutter_test.dart';
import 'package:trace_raffine/features/reviews/domain/entities/review.dart';

void main() {
  group('Review', () {
    test('should create review', () {
      final review = Review(
        userId: 'user1',
        productId: 'prod1',
        rating: 5,
        reviewText: 'Great product!',
      );

      expect(review.userId, 'user1');
      expect(review.productId, 'prod1');
      expect(review.rating, 5);
      expect(review.reviewText, 'Great product!');
    });

    test('should parse fromJson', () {
      final json = {
        '\$id': 'review1',
        'user_id': 'user1',
        'product_id': 'prod1',
        'rating': 4,
        'review_text': 'Good',
      };

      final review = Review.fromJson(json);
      expect(review.id, 'review1');
      expect(review.rating, 4);
      expect(review.reviewText, 'Good');
    });
  });
}
