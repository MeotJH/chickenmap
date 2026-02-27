import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_sizes.dart';
import 'package:front/presentation/providers/store_providers.dart';
import 'package:front/presentation/widgets/review_card.dart';
import 'package:front/presentation/widgets/score_row.dart';
import 'package:front/presentation/widgets/section_title.dart';
import 'package:go_router/go_router.dart';

// 지점 상세 화면이다.
class StoreDetailPage extends ConsumerWidget {
  final String storeId;

  const StoreDetailPage({
    super.key,
    required this.storeId,
  });

  @override
  // 지점 상세 정보와 리뷰를 구성한다.
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(storeDetailProvider(storeId));
    final breakdown = ref.watch(storeBreakdownProvider(storeId));
    final reviews = ref.watch(storeReviewsProvider(storeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('지점 상세'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            store.when(
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(data.address),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('지점 정보를 불러오지 못했어요.'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: breakdown.when(
                data: (data) => Column(
                  children: [
                    ScoreRow(label: '바삭함', value: data.crispy),
                    const SizedBox(height: 8),
                    ScoreRow(label: '육즙', value: data.juicy),
                    const SizedBox(height: 8),
                    ScoreRow(label: '염도', value: data.salty),
                    const SizedBox(height: 8),
                    ScoreRow(label: '기름상태', value: data.oil),
                    const SizedBox(height: 8),
                    ScoreRow(label: '닭품질', value: data.chickenQuality),
                    const SizedBox(height: 8),
                    ScoreRow(label: '튀김완성도', value: data.fryQuality),
                    const SizedBox(height: 8),
                    ScoreRow(label: '양', value: data.portion),
                    const Divider(height: 24),
                    ScoreRow(label: '총점', value: data.overall),
                  ],
                ),
                loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const Text('점수 정보를 불러오지 못했어요.'),
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle(title: '리뷰'),
            const SizedBox(height: 12),
            reviews.when(
              data: (items) => Column(
                children: items
                    .map((review) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ReviewCard(review: review),
                        ))
                    .toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('리뷰를 불러오지 못했어요.'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/review/write'),
                child: const Text('이 지점에서 먹은 치킨 리뷰 남기기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
