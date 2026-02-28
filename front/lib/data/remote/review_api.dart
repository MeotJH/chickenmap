import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/domain/entities/review.dart';

// 리뷰 API 호출을 담당한다.
class ReviewApi {
  ReviewApi({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  Future<Review> createReview(ReviewCreateRequest payload) async {
    final response = await _dio.post(
      '$_baseUrl/api/chickenmap/reviews',
      data: payload.toJson(),
    );
    return _reviewFromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Review>> fetchMyReviews() async {
    final response = await _dio.get('$_baseUrl/api/chickenmap/reviews/me');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => _reviewFromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Review> fetchReviewDetail(String reviewId) async {
    final response = await _dio.get('$_baseUrl/api/chickenmap/reviews/$reviewId');
    return _reviewFromJson(response.data as Map<String, dynamic>);
  }
}

// 리뷰 생성 요청 모델이다.
class ReviewCreateRequest {
  final String storeName;
  final String address;
  final String brandId;
  final String menuName;
  final Map<String, double> scores;
  final double overall;
  final String comment;

  const ReviewCreateRequest({
    required this.storeName,
    required this.address,
    required this.brandId,
    required this.menuName,
    required this.scores,
    required this.overall,
    required this.comment,
  });

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'address': address,
        'brandId': brandId,
        'menuName': menuName,
        'scores': scores,
        'overall': overall,
        'comment': comment,
      };
}

Review _reviewFromJson(Map<String, dynamic> json) {
  final scores = _scoresFromJson(json['scores']);
  return Review(
    id: json['id'] as String? ?? '',
    storeName: json['storeName'] as String? ?? '',
    brandName: json['brandName'] as String? ?? '',
    menuName: json['menuName'] as String? ?? '',
    menuCategory: json['menuCategory'] as String? ?? '',
    scores: scores,
    overall: (json['overall'] as num?)?.toDouble() ?? 0,
    comment: json['comment'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
  );
}

Map<String, double> _scoresFromJson(dynamic raw) {
  if (raw is! Map<String, dynamic>) return const {};
  return {
    for (final entry in raw.entries)
      entry.key: (entry.value as num?)?.toDouble() ?? 0,
  };
}
