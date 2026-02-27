import 'package:front/domain/entities/review.dart';
import 'package:front/data/remote/review_api.dart';

// 리뷰 데이터를 제공하는 저장소 인터페이스다.
abstract class ReviewRepository {
  // 내 리뷰 목록을 조회한다.
  Future<List<Review>> fetchMyReviews();

  // 리뷰 상세를 조회한다.
  Future<Review> fetchReviewDetail(String reviewId);

  // 리뷰를 생성한다.
  Future<Review> createReview(ReviewCreateRequest payload);
}
