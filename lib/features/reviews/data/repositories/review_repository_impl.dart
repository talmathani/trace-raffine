import 'package:trace_raffine/core/appwrite/appwrite_service.dart';
import 'package:trace_raffine/core/functions/function_invoker.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FunctionInvoker _functionInvoker;

  ReviewRepositoryImpl({FunctionInvoker? functionInvoker})
    : _functionInvoker = functionInvoker ?? FunctionInvoker.create();

  @override
  Future<List<Review>> getReviews(String productId) async {
    final userId = (await AppwriteService.account.get()).$id;
    final result = await _functionInvoker.listReviews(
      userId: userId,
      productId: productId,
    );
    if (result['success'] != true) {
      throw StateError(
        result['error']?.toString() ?? 'Unable to load reviews.',
      );
    }

    final reviews = result['reviews'];
    if (reviews is! List) return const <Review>[];

    return reviews
        .whereType<Map>()
        .map((raw) {
          final data = raw['data'] is Map
              ? Map<String, dynamic>.from(raw['data'] as Map)
              : Map<String, dynamic>.from(raw);
          final id = raw[r'$id']?.toString() ?? raw['id']?.toString();
          if (id != null && id.isNotEmpty) data[r'$id'] = id;
          return ReviewModel.fromJson(data);
        })
        .toList(growable: false);
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

    final result = await _functionInvoker.reviewProduct(
      userId: model.userId,
      productId: model.productId,
      rating: model.rating,
      reviewText: model.reviewText,
    );

    if (result['success'] != true) {
      throw StateError(
        result['error']?.toString() ?? 'Review could not be submitted.',
      );
    }

    return ReviewModel(
      id: result['reviewId']?.toString() ?? model.id,
      userId: model.userId,
      productId: model.productId,
      rating: model.rating,
      reviewText: model.reviewText,
      createdAt: model.createdAt,
    );
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    final userId = (await AppwriteService.account.get()).$id;
    final result = await _functionInvoker.deleteReview(
      userId: userId,
      reviewId: reviewId,
    );
    if (result['success'] != true) {
      throw StateError(
        result['error']?.toString() ?? 'Unable to delete review.',
      );
    }
  }
}
