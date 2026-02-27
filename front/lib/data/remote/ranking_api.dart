import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/domain/entities/brand_menu_ranking.dart';
import 'package:front/domain/entities/rating_breakdown.dart';
import 'package:front/domain/entities/review.dart';

// 랭킹 API 호출을 담당한다.
class RankingApi {
  RankingApi({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  Future<List<BrandMenuRanking>> fetchRankings() async {
    final response = await _dio.get('$_baseUrl/api/chickenmap/rankings');
    final data = response.data as List<dynamic>;
    return data
        .map((item) => _rankingFromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<RatingBreakdown> fetchRankingBreakdown(String rankingId) async {
    final response = await _dio.get(
      '$_baseUrl/api/chickenmap/rankings/$rankingId/breakdown',
    );
    final json = response.data as Map<String, dynamic>;
    return _breakdownFromJson(json);
  }

  Future<List<Review>> fetchRankingReviews(String rankingId) async {
    final response = await _dio.get(
      '$_baseUrl/api/chickenmap/rankings/$rankingId/reviews',
    );
    final data = response.data as List<dynamic>;
    return data
        .map((item) => _reviewFromJson(item as Map<String, dynamic>))
        .toList();
  }
}

BrandMenuRanking _rankingFromJson(Map<String, dynamic> json) {
  return BrandMenuRanking(
    id: json['id'] as String? ?? '',
    brandId: json['brandId'] as String? ?? '',
    menuId: json['menuId'] as String? ?? '',
    brandName: json['brandName'] as String? ?? '',
    menuName: json['menuName'] as String? ?? '',
    category: json['category'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    reviewCount: json['reviewCount'] as int? ?? 0,
    highlightScoreA: (json['highlightScoreA'] as num?)?.toDouble() ?? 0,
    highlightLabelA: json['highlightLabelA'] as String? ?? '',
    highlightScoreB: (json['highlightScoreB'] as num?)?.toDouble() ?? 0,
    highlightLabelB: json['highlightLabelB'] as String? ?? '',
    imageUrl: json['imageUrl'] as String? ?? '',
    brandLogoUrl: json['brandLogoUrl'] as String? ?? '',
  );
}

RatingBreakdown _breakdownFromJson(Map<String, dynamic> json) {
  return RatingBreakdown(
    crispy: (json['crispy'] as num?)?.toDouble() ?? 0,
    juicy: (json['juicy'] as num?)?.toDouble() ?? 0,
    salty: (json['salty'] as num?)?.toDouble() ?? 0,
    oil: (json['oil'] as num?)?.toDouble() ?? 0,
    chickenQuality: (json['chickenQuality'] as num?)?.toDouble() ?? 0,
    fryQuality: (json['fryQuality'] as num?)?.toDouble() ?? 0,
    portion: (json['portion'] as num?)?.toDouble() ?? 0,
    overall: (json['overall'] as num?)?.toDouble() ?? 0,
  );
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
