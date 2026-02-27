import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/data/mock/mock_data.dart';
import 'package:front/data/remote/ranking_api.dart';
import 'package:front/data/repositories/remote_ranking_repository.dart';
import 'package:front/data/repositories/mock_review_repository.dart';
import 'package:front/data/remote/review_api.dart';
import 'package:front/data/repositories/remote_review_repository.dart';
import 'package:front/data/remote/store_api.dart';
import 'package:front/data/repositories/remote_store_repository.dart';
import 'package:front/data/remote/menu_api.dart';
import 'package:front/data/remote/place_search_api.dart';
import 'package:front/data/repositories/remote_menu_repository.dart';
import 'package:front/data/repositories/remote_place_search_repository.dart';
import 'package:front/domain/repositories/ranking_repository.dart';
import 'package:front/domain/repositories/review_repository.dart';
import 'package:front/domain/repositories/store_repository.dart';
import 'package:front/domain/repositories/menu_repository.dart';
import 'package:front/domain/repositories/place_search_repository.dart';

// 목업 데이터 소스를 제공하는 Provider다.
final mockDataSourceProvider = Provider<MockDataSource>((ref) {
  return MockDataSource();
});

// 랭킹 저장소 Provider다.
final rankingRepositoryProvider = Provider<RankingRepository>((ref) {
  final api = ref.watch(rankingApiProvider);
  return RemoteRankingRepository(api);
});

// 지점 저장소 Provider다.
final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  final api = ref.watch(storeApiProvider);
  return RemoteStoreRepository(api);
});

// 리뷰 저장소 Provider다.
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final api = ref.watch(reviewApiProvider);
  return RemoteReviewRepository(api);
});

// 리뷰 API 클라이언트를 제공한다.
final reviewApiProvider = Provider<ReviewApi>((ref) {
  return ReviewApi();
});

// 랭킹 API 클라이언트를 제공한다.
final rankingApiProvider = Provider<RankingApi>((ref) {
  return RankingApi();
});

// 메뉴 API 클라이언트를 제공한다.
final menuApiProvider = Provider<MenuApi>((ref) {
  return MenuApi();
});

// 지점 API 클라이언트를 제공한다.
final storeApiProvider = Provider<StoreApi>((ref) {
  return StoreApi();
});

// 장소 검색 API 클라이언트를 제공한다.
final placeSearchApiProvider = Provider<PlaceSearchApi>((ref) {
  return PlaceSearchApi();
});

// 메뉴 저장소 Provider다.
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  final api = ref.watch(menuApiProvider);
  return RemoteMenuRepository(api);
});

// 장소 검색 저장소 Provider다.
final placeSearchRepositoryProvider = Provider<PlaceSearchRepository>((ref) {
  final api = ref.watch(placeSearchApiProvider);
  return RemotePlaceSearchRepository(api);
});
