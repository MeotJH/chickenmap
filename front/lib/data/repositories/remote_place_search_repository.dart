import 'package:front/data/remote/place_search_api.dart';
import 'package:front/domain/entities/place_search_result.dart';
import 'package:front/domain/repositories/place_search_repository.dart';

// 원격 API 기반의 장소 검색 저장소 구현체다.
class RemotePlaceSearchRepository implements PlaceSearchRepository {
  final PlaceSearchApi _api;

  RemotePlaceSearchRepository(this._api);

  @override
  Future<List<PlaceSearchResult>> searchPlaces(String query) {
    return _api.search(query);
  }
}
