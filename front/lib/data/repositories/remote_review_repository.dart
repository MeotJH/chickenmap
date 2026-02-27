import 'package:front/data/remote/review_api.dart';
import 'package:front/domain/entities/review.dart';
import 'package:front/domain/repositories/review_repository.dart';

// 원격 API 기반의 리뷰 저장소 구현체다.
class RemoteReviewRepository implements ReviewRepository {
  final ReviewApi _api;

  RemoteReviewRepository(this._api);

  @override
  Future<List<Review>> fetchMyReviews() {
    return _api.fetchMyReviews();
  }

  @override
  Future<Review> fetchReviewDetail(String reviewId) {
    return _api.fetchReviewDetail(reviewId);
  }

  @override
  Future<Review> createReview(ReviewCreateRequest payload) {
    return _api.createReview(payload);
  }
}
