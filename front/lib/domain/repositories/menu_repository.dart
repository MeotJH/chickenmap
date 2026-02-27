import 'package:front/domain/entities/brand.dart';
import 'package:front/domain/entities/menu.dart';

// 브랜드/메뉴 데이터를 제공하는 저장소 인터페이스다.
abstract class MenuRepository {
  // 브랜드 목록을 조회한다.
  Future<List<Brand>> fetchBrands();

  // 브랜드별 메뉴 목록을 조회한다.
  Future<List<Menu>> fetchMenus(String brandId, {String? query});
}
