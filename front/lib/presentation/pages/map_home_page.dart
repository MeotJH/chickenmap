import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_colors.dart';
import 'package:front/domain/entities/place_search_result.dart';
import 'package:front/presentation/providers/store_providers.dart';
import 'package:front/presentation/providers/app_providers.dart';
import 'package:front/presentation/widgets/store_card.dart';
import 'package:go_router/go_router.dart';
import 'package:front/presentation/widgets/naver_map_view.dart';
import 'package:front/domain/entities/store_summary.dart';

// 지점 평점 지도를 보여주는 홈 화면이다.
class MapHomePage extends ConsumerStatefulWidget {
  const MapHomePage({super.key});

  @override
  ConsumerState<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends ConsumerState<MapHomePage> {
  final _searchController = TextEditingController();

  List<PlaceSearchResult> _results = [];
  bool _isSearching = false;
  String? _searchError;
  StoreSummary? _selectedStore;
  final String _chickenMarkerIconUrl = _buildChickenMarkerIconUrl();

  static String _buildChickenMarkerIconUrl() {
    const svg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28">
  <text x="50%" y="50%" text-anchor="middle" dominant-baseline="central" font-size="20">🍗</text>
</svg>
''';
    return 'data:image/svg+xml;utf8,${Uri.encodeComponent(svg)}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    try {
      final repository = ref.read(placeSearchRepositoryProvider);
      final results = await repository.searchPlaces(query.trim());
      setState(() {
        _results = results;
      });
    } catch (_) {
      setState(() {
        _searchError = '검색에 실패했어요. 다시 시도해주세요.';
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _openReviewWrite(PlaceSearchResult item) {
    final address = item.roadAddress.isNotEmpty
        ? item.roadAddress
        : item.address;
    final uri = Uri(
      path: '/review/write',
      queryParameters: {'storeName': item.name, 'address': address},
    );
    context.push(uri.toString());
  }

  @override
  // 지도와 바텀시트를 함께 렌더링한다.
  Widget build(BuildContext context) {
    if (kIsWeb) {
      final webMarkers = [
        MapMarkerData(
          id: 'chicken-1',
          lat: 37.5665,
          lng: 126.9780,
          caption: '?? ??',
          iconUrl: _chickenMarkerIconUrl,
        ),
      ];
      return Scaffold(
        body: buildNaverMapView(
          context: context,
          lat: 37.5665,
          lng: 126.9780,
          zoom: 14,
          markers: webMarkers,
        ),
      );
    }

    final stores = ref.watch(nearbyStoresProvider);
    final storeItems = stores.asData?.value ?? [];
    final markers = storeItems
        .map(
          (store) => MapMarkerData(
            id: store.id,
            lat: store.lat,
            lng: store.lng,
            caption: store.name,
            description: store.address,
            iconUrl: _chickenMarkerIconUrl,
          ),
        )
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          // 네이버 지도 위젯 (API 키 설정 필요)
          KeyedSubtree(
            key: const ValueKey('map-static'),
            child: buildNaverMapView(
              context: context,
              lat: 37.5665,
              lng: 126.9780,
              zoom: 14,
              markers: markers,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.menu,
                          color: AppColors.textPrimary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: _searchPlaces,
                          decoration: InputDecoration(
                            hintText: '치킨집 검색',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _searchPlaces(_searchController.text),
                        icon: const Icon(Icons.search, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (_isSearching ||
                      _results.isNotEmpty ||
                      _searchError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _SearchResultPanel(
                        isLoading: _isSearching,
                        errorMessage: _searchError,
                        results: _results,
                        onSelect: _openReviewWrite,
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _MapChip(label: '영업중', selected: true),
                        _MapChip(label: '평점 높은 순'),
                        _MapChip(label: '가까운 순'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.28,
              minChildSize: 0.2,
              maxChildSize: 0.6,
              builder: (context, controller) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: stores.when(
                          data: (items) => ListView(
                            controller: controller,
                            children: [
                              SizedBox(
                                height: 140,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return StoreCard(
                                      store: items[index],
                                      onTap: () => context.go(
                                        '/map/store/${items[index].id}',
                                      ),
                                    );
                                  },
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemCount: items.length,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...items.map(
                                (store) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    tileColor: AppColors.backgroundLight,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    title: Text(store.name),
                                    subtitle: Text(
                                      '${store.rating} · ${store.reviewCount} 리뷰',
                                    ),
                                    onTap: () =>
                                        context.go('/map/store/${store.id}'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, __) =>
                              const Center(child: Text('지점 정보를 불러오지 못했어요.')),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_selectedStore != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 220,
              child: GestureDetector(
                onTap: () => context.go('/map/store/${_selectedStore!.id}'),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.backgroundLight,
                        child: const Icon(
                          Icons.store,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedStore!.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_selectedStore!.rating} · ${_selectedStore!.reviewCount} 리뷰',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 지도 상단 필터 칩을 표현한다.
class _MapChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _MapChip({required this.label, this.selected = false});

  @override
  // 지도 필터 칩 UI를 구성한다.
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {},
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SearchResultPanel extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<PlaceSearchResult> results;
  final ValueChanged<PlaceSearchResult> onSelect;

  const _SearchResultPanel({
    required this.isLoading,
    required this.errorMessage,
    required this.results,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),
          if (!isLoading && errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (!isLoading && errorMessage == null)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = results[index];
                final address = item.roadAddress.isNotEmpty
                    ? item.roadAddress
                    : item.address;
                return ListTile(
                  leading: const Icon(Icons.place, color: AppColors.primary),
                  title: Text(item.name),
                  subtitle: Text(address),
                  onTap: () => onSelect(item),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: results.length,
            ),
        ],
      ),
    );
  }
}
