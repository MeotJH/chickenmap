import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

// 모바일(Android/iOS)에서 네이버 지도 SDK를 초기화한다.
Future<void> initNaverMapImpl(String clientId) async {
  await FlutterNaverMap().init(
    clientId: clientId,
    onAuthFailed: (ex) {
      // 401: clientId 오류 or 콘솔에 등록된 패키지명/번들ID 불일치
      // 429: Maps 서비스 미선택/쿼터 초과
      // 800: clientId 미지정
      debugPrint('NaverMap auth failed: $ex');
    },
  );
}
