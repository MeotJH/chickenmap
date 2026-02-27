import 'naver_map_init_stub.dart'
    if (dart.library.html) 'naver_map_init_web.dart'
    if (dart.library.io) 'naver_map_init_mobile.dart';

// 플랫폼별 네이버 지도 SDK 초기화를 수행한다.
Future<void> initNaverMap(String clientId) {
  return initNaverMapImpl(clientId);
}
