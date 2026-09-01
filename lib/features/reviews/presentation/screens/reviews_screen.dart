import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/review.dart';
import '../providers/review_providers.dart';

class ReviewsScreen extends ConsumerWidget {
  final String productId;

  const ReviewsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewRepository = ref.watch(reviewRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: FutureBuilder<List<Review>>(
        future: reviewRepository.getReviews(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  title: Text('Rating: ${review.rating}/5'),
                  subtitle: review.reviewText != null ? Text(review.reviewText!) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
