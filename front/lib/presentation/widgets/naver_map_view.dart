import 'package:flutter/widgets.dart';

import 'naver_map_view_stub.dart'
    if (dart.library.html) 'naver_map_view_web.dart'
    if (dart.library.io) 'naver_map_view_mobile.dart';

// 플랫폼별 네이버 지도 위젯을 생성하는 진입점이다.
Widget buildNaverMapView({
  required BuildContext context,
  required double lat,
  required double lng,
  required double zoom,
  required List<MapMarkerData> markers,
  String? selectedMarkerId,
  ValueChanged<String>? onMarkerTap,
  ValueChanged<dynamic>? onMapReady,
}) {
  return buildNaverMapViewImpl(
    context: context,
    lat: lat,
    lng: lng,
    zoom: zoom,
    markers: markers,
    selectedMarkerId: selectedMarkerId,
    onMarkerTap: onMarkerTap,
    onMapReady: onMapReady,
  );
}

// 지도에 표시할 마커 데이터다.
class MapMarkerData {
  final String id;
  final double lat;
  final double lng;
  final String caption;
  final String? description;
  final String? iconUrl;

  const MapMarkerData({
    required this.id,
    required this.lat,
    required this.lng,
    required this.caption,
    this.description,
    this.iconUrl,
  });
}
