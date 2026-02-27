import 'package:flutter/widgets.dart';

import 'naver_map_view.dart';

// 지원하지 않는 플랫폼에서 대체 화면을 제공한다.
Widget buildNaverMapViewImpl({
  required BuildContext context,
  required double lat,
  required double lng,
  required double zoom,
  required List<MapMarkerData> markers,
  ValueChanged<String>? onMarkerTap,
  ValueChanged<dynamic>? onMapReady,
}) {
  return const SizedBox.shrink();
}
