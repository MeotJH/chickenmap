import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_colors.dart';
import 'package:front/core/constants/rating_dimensions.dart';
import 'package:front/core/utils/formatters.dart';
import 'package:front/domain/entities/review.dart';
import 'package:front/presentation/providers/review_providers.dart';

// 리뷰 상세 화면이다.
class ReviewDetailPage extends ConsumerWidget {
  final String reviewId;
  final Review? initialReview;

  const ReviewDetailPage({
    super.key,
    required this.reviewId,
    this.initialReview,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewAsync = ref.watch(reviewDetailProvider(reviewId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('리뷰 상세'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: reviewAsync.when(
          data: (review) => _ReviewDetailBody(review: review),
          loading: () => initialReview == null
              ? const Center(child: CircularProgressIndicator())
              : _ReviewDetailBody(review: initialReview!),
          error: (_, __) => initialReview == null
              ? const Center(child: Text('리뷰를 불러오지 못했어요.'))
              : _ReviewDetailBody(review: initialReview!),
        ),
      ),
    );
  }
}

class _ReviewDetailBody extends StatelessWidget {
  final Review review;

  const _ReviewDetailBody({required this.review});

  @override
  Widget build(BuildContext context) {
    final entries = review.scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      children: [
        Text(
          '${review.brandName} · ${review.menuName}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          review.storeName,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.star, size: 18, color: AppColors.ratingStar),
            const SizedBox(width: 6),
            Text(
              RatingFormatter.score(review.overall),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 10),
            Text(
              '${review.createdAt.year}.${review.createdAt.month}.${review.createdAt.day}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...entries.map(
          (entry) => _ScoreRow(label: ratingLabel(entry.key), value: entry.value),
        ),
        const SizedBox(height: 16),
        const Text(
          '코멘트',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(review.comment),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final double value;

  const _ScoreRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            RatingFormatter.score(value),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
