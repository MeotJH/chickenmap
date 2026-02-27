// 장소 검색 결과를 표현하는 엔티티다.
class PlaceSearchResult {
  final String name;
  final String address;
  final String roadAddress;
  final String category;
  final String phone;
  final String link;
  final int mapx;
  final int mapy;

  const PlaceSearchResult({
    required this.name,
    required this.address,
    required this.roadAddress,
    required this.category,
    required this.phone,
    required this.link,
    required this.mapx,
    required this.mapy,
  });
}
