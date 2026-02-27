import 'package:front/data/mock/mock_data.dart';
import 'package:front/domain/entities/review.dart';
import 'package:front/data/remote/review_api.dart';
import 'package:front/domain/repositories/review_repository.dart';

// 목업 리뷰 저장소 구현체다.
class MockReviewRepository implements ReviewRepository {
  MockReviewRepository(this._dataSource);

  final MockDataSource _dataSource;

  @override
  // 내 리뷰를 목업 데이터로 반환한다.
  Future<List<Review>> fetchMyReviews() async {
    return _dataSource.reviews();
  }

  @override
  Future<Review> fetchReviewDetail(String reviewId) async {
    return _dataSource.reviews().first;
  }

  @override
  Future<Review> createReview(ReviewCreateRequest payload) async {
    return _dataSource.reviews().first;
  }
}
