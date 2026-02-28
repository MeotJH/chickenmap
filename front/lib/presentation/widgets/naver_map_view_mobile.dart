import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'naver_map_view.dart';

// 모바일(Android/iOS)용 네이버 지도 위젯 구현이다.
Widget buildNaverMapViewImpl({
  required BuildContext context,
  required double lat,
  required double lng,
  required double zoom,
  required List<MapMarkerData> markers,
  String? selectedMarkerId,
  ValueChanged<String>? onMarkerTap,
  ValueChanged<dynamic>? onMapReady,
}) {
  return NaverMap(
    options: NaverMapViewOptions(
      initialCameraPosition: NCameraPosition(
        target: NLatLng(lat, lng),
        zoom: zoom,
      ),
    ),
    onMapReady: (controller) async {
      for (final marker in markers) {
        final nMarker = NMarker(
          id: marker.id,
          position: NLatLng(marker.lat, marker.lng),
        );
        // Keep the default marker icon so tap hit-area remains reliable.
        nMarker.setCaption(
          const NOverlayCaption(
            text: '\u{1F357}',
            textSize: 18,
            color: Colors.black,
          ),
        );
        nMarker.setOnTapListener((overlay) {
          onMarkerTap?.call(marker.id);
        });
        controller.addOverlay(nMarker);
      }
      onMapReady?.call(controller);
    },
  );
}
