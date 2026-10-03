import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';

import '../../domain/entities/review.dart';
import '../providers/review_providers.dart';

class ReviewsScreen extends ConsumerWidget {
  final String productId;

  const ReviewsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewRepository = ref.watch(reviewRepositoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: MaisonAppBar(title: 'التقييمات'),
      body: FutureBuilder<List<Review>>(
        future: reviewRepository.getReviews(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _ReviewsLoadingState();
          }

          if (snapshot.hasError) {
            return const _ReviewsMessageState(
              title: 'تعذر تحميل التقييمات',
              detail: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
            );
          }

          final reviews = snapshot.data ?? [];

          if (reviews.isEmpty) {
            return const _ReviewsMessageState(
              title: 'لا توجد تقييمات حتى الآن',
              detail: 'لم تتم إضافة أي تقييم لهذا التصميم بعد.',
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 56),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];

              return _EditorialReviewEntry(index: index, review: review);
            },
          );
        },
      ),
    );
  }
}

class _EditorialReviewEntry extends StatelessWidget {
  final int index;
  final Review review;

  const _EditorialReviewEntry({required this.index, required this.review});

  @override
  Widget build(BuildContext context) {
    final sequence = (index + 1).toString().padLeft(2, '0');
    final rating = review.rating.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                sequence,
                style: const TextStyle(
                  fontFamily: AppTheme.fontEditorial,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.softRose,
                  height: 1,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'REVIEW',
                  style: TextStyle(
                    fontFamily: AppTheme.fontTechnical,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.6,
                    color: AppTheme.mutedIvory.withValues(alpha: 0.62),
                    height: 1,
                  ),
                ),
              ),
              Text(
                '$rating/5',
                style: const TextStyle(
                  fontFamily: AppTheme.fontTechnical,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.softRose,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(
              5,
              (starIndex) => Padding(
                padding: EdgeInsetsDirectional.only(
                  end: starIndex == 4 ? 0 : 5,
                ),
                child: Icon(
                  starIndex < review.rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 18,
                  color: starIndex < review.rating
                      ? AppTheme.softRose
                      : AppTheme.divider,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (review.reviewText != null && review.reviewText!.trim().isNotEmpty)
            Text(
              review.reviewText!,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.warmIvory,
                height: 1.75,
              ),
            )
          else
            const Text(
              'بدون تعليق مكتوب',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.secondaryText,
                height: 1.6,
              ),
            ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1, color: AppTheme.divider),
        ],
      ),
    );
  }
}

class _ReviewsLoadingState extends StatelessWidget {
  const _ReviewsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'REVIEWS',
              style: TextStyle(
                fontFamily: AppTheme.fontTechnical,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: AppTheme.softRose.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 54,
              height: 1,
              color: AppTheme.softRose.withValues(alpha: 0.58),
            ),
            const SizedBox(height: 16),
            const Text(
              'جاري تحميل التقييمات',
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.mutedIvory,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsMessageState extends StatelessWidget {
  final String title;
  final String detail;

  const _ReviewsMessageState({required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'REVIEWS',
              style: TextStyle(
                fontFamily: AppTheme.fontTechnical,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 3,
                color: AppTheme.softRose.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.warmIvory,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.secondaryText,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
