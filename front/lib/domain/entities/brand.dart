// 브랜드 정보를 표현하는 엔티티다.
class Brand {
  final String id;
  final String name;
  final String logoUrl;

  const Brand({
    required this.id,
    required this.name,
    required this.logoUrl,
  });
}
