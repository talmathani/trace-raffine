import 'package:appwrite/appwrite.dart';
import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_database_constants.dart';
import '../models/review_model.dart';

class ReviewDataSource {
  final Databases databases;

  ReviewDataSource(this.databases);

  factory ReviewDataSource.create() {
    final client = AppwriteConfig.createClient();
    return ReviewDataSource(Databases(client));
  }

  Future<List<ReviewModel>> getReviews(String productId) async {
    final response = await databases.listDocuments(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.reviewsCollection,
      queries: [
        Query.equal('product_id', productId),
        Query.orderDesc('created_at'),
      ],
    );
    return response.documents.map((doc) => ReviewModel.fromJson(doc.data)).toList();
  }

  Future<ReviewModel> addReview(ReviewModel review) async {
    final doc = await databases.createDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.reviewsCollection,
      documentId: ID.unique(),
      data: review.toJson(),
    );
    return ReviewModel.fromJson(doc.data);
  }

  Future<void> deleteReview(String reviewId) async {
    await databases.deleteDocument(
      databaseId: AppwriteDatabaseConstants.databaseId,
      collectionId: AppwriteDatabaseConstants.reviewsCollection,
      documentId: reviewId,
    );
  }
}
