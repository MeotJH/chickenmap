import 'package:front/domain/entities/place_search_result.dart';

// 장소 검색 데이터를 제공하는 저장소 인터페이스다.
abstract class PlaceSearchRepository {
  // 키워드로 장소를 검색한다.
  Future<List<PlaceSearchResult>> searchPlaces(String query);
}
