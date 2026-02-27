// 항목별 평점 분해 데이터를 표현하는 엔티티다.
class RatingBreakdown {
  final double crispy;
  final double juicy;
  final double salty;
  final double oil;
  final double chickenQuality;
  final double fryQuality;
  final double portion;
  final double overall;

  const RatingBreakdown({
    required this.crispy,
    required this.juicy,
    required this.salty,
    required this.oil,
    required this.chickenQuality,
    required this.fryQuality,
    required this.portion,
    required this.overall,
  });
}
