import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../../../../core/appwrite/appwrite_database_service.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final AppwriteDatabaseService _databaseService;

  ReviewRepositoryImpl(this._databaseService);

  @override
  Future<List<Review>> getReviews(String productId) async {
    final response = await _databaseService.listDocuments(
      collectionId: AppwriteDatabaseConstants.reviewsCollectionId,
    );

    return response.documents
        .map((doc) => ReviewModel.fromJson({
              ...doc.data,
              r'$id': doc.$id,
            }))
        .where((review) => review.productId == productId)
        .toList();
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

    final documentId =
        model.id != null && model.id!.isNotEmpty ? model.id : null;

    final doc = await _databaseService.createDocument(
      collectionId: AppwriteDatabaseConstants.reviewsCollectionId,
      data: {
        'user_id': model.userId,
        'product_id': model.productId,
        'rating': model.rating,
        'review_text': model.reviewText,
        'created_at': model.createdAt?.toIso8601String(),
      },
      documentId: documentId,
    );

    return ReviewModel.fromJson({
      ...doc.data,
      r'$id': doc.$id,
    });
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await _databaseService.deleteDocument(
      collectionId: AppwriteDatabaseConstants.reviewsCollectionId,
      documentId: reviewId,
    );
  }
}
