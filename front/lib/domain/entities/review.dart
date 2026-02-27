// 리뷰 한 건을 표현하는 엔티티다.
class Review {
  final String id;
  final String storeName;
  final String brandName;
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
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.storeName,
    required this.brandName,
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
    required this.createdAt,
  });
}
