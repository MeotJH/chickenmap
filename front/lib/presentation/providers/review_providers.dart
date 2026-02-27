import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/domain/entities/review.dart';
import 'package:front/presentation/providers/app_providers.dart';

// 내 리뷰 리스트를 제공하는 FutureProvider다.
final myReviewsProvider = FutureProvider<List<Review>>((ref) async {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.fetchMyReviews();
});

// 리뷰 상세를 제공하는 FutureProvider다.
final reviewDetailProvider = FutureProvider.family<Review, String>((ref, reviewId) async {
  final repository = ref.watch(reviewRepositoryProvider);
  return repository.fetchReviewDetail(reviewId);
});
