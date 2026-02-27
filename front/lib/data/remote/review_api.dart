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
  final double crispy;
  final double juicy;
  final double salty;
  final double oil;
  final double chickenQuality;
  final double fryQuality;
  final double portion;
  final double overall;
  final String comment;

  const ReviewCreateRequest({
    required this.storeName,
    required this.address,
    required this.brandId,
    required this.menuName,
    required this.crispy,
    required this.juicy,
    required this.salty,
    required this.oil,
    required this.chickenQuality,
    required this.fryQuality,
    required this.portion,
    required this.overall,
    required this.comment,
  });

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'address': address,
        'brandId': brandId,
        'menuName': menuName,
        'crispy': crispy,
        'juicy': juicy,
        'salty': salty,
        'oil': oil,
        'chickenQuality': chickenQuality,
        'fryQuality': fryQuality,
        'portion': portion,
        'overall': overall,
        'comment': comment,
      };
}

Review _reviewFromJson(Map<String, dynamic> json) {
  return Review(
    id: json['id'] as String? ?? '',
    storeName: json['storeName'] as String? ?? '',
    brandName: json['brandName'] as String? ?? '',
    menuName: json['menuName'] as String? ?? '',
    crispy: (json['crispy'] as num?)?.toDouble() ?? 0,
    juicy: (json['juicy'] as num?)?.toDouble() ?? 0,
    salty: (json['salty'] as num?)?.toDouble() ?? 0,
    oil: (json['oil'] as num?)?.toDouble() ?? 0,
    chickenQuality: (json['chickenQuality'] as num?)?.toDouble() ?? 0,
    fryQuality: (json['fryQuality'] as num?)?.toDouble() ?? 0,
    portion: (json['portion'] as num?)?.toDouble() ?? 0,
    overall: (json['overall'] as num?)?.toDouble() ?? 0,
    comment: json['comment'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
  );
}
