import 'package:front/data/remote/menu_api.dart';
import 'package:front/domain/entities/brand.dart';
import 'package:front/domain/entities/menu.dart';
import 'package:front/domain/repositories/menu_repository.dart';

// 원격 API 기반의 메뉴 저장소 구현체다.
class RemoteMenuRepository implements MenuRepository {
  final MenuApi _api;

  RemoteMenuRepository(this._api);

  @override
  Future<List<Brand>> fetchBrands() {
    return _api.fetchBrands();
  }

  @override
  Future<List<Menu>> fetchMenus(String brandId, {String? query}) {
    return _api.fetchMenus(brandId, query: query);
  }
}
