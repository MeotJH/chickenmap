import 'package:front/data/remote/ranking_api.dart';
import 'package:front/domain/entities/brand_menu_ranking.dart';
import 'package:front/domain/entities/rating_breakdown.dart';
import 'package:front/domain/entities/review.dart';
import 'package:front/domain/repositories/ranking_repository.dart';

// 원격 API 기반의 랭킹 저장소 구현체다.
class RemoteRankingRepository implements RankingRepository {
  RemoteRankingRepository(this._api);

  final RankingApi _api;

  @override
  // 랭킹 리스트를 원격 API로 반환한다.
  Future<List<BrandMenuRanking>> fetchRankings() async {
    return _api.fetchRankings();
  }

  @override
  // 랭킹 상세 분해 점수를 원격 API로 반환한다.
  Future<RatingBreakdown> fetchRankingBreakdown(String rankingId) async {
    return _api.fetchRankingBreakdown(rankingId);
  }

  @override
  // 랭킹 리뷰 목록을 원격 API로 반환한다.
  Future<List<Review>> fetchRankingReviews(String rankingId) async {
    return _api.fetchRankingReviews(rankingId);
  }
}
