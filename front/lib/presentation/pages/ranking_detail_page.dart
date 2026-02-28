import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/app/write_chicken_review_button.dart';
import 'package:front/core/constants/app_sizes.dart';
import 'package:front/core/constants/rating_dimensions.dart';
import 'package:front/presentation/providers/ranking_providers.dart';
import 'package:front/presentation/widgets/review_card.dart';
import 'package:front/presentation/widgets/score_row.dart';
import 'package:front/presentation/widgets/section_title.dart';
import 'package:front/domain/entities/brand_menu_ranking.dart';
import 'package:go_router/go_router.dart';

// 랭킹 상세 화면이다.
class RankingDetailPage extends ConsumerWidget {
  final String rankingId;
  final BrandMenuRanking? ranking;

  const RankingDetailPage({super.key, required this.rankingId, this.ranking});

  List<MapEntry<String, double>> _scoreEntries(Map<String, double> scores) {
    final entries = scores.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  @override
  // 랭킹 상세 점수와 리뷰를 구성한다.
  Widget build(BuildContext context, WidgetRef ref) {
    final breakdown = ref.watch(rankingBreakdownProvider(rankingId));
    final reviews = ref.watch(rankingReviewsProvider(rankingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('랭킹 상세'),
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
            Text(
              ranking == null
                  ? '랭킹 상세'
                  : '${ranking!.brandName} ${ranking!.menuName}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                    ..._scoreEntries(data.scores).expand(
                      (entry) => [
                        ScoreRow(
                          label: ratingLabel(entry.key),
                          value: entry.value,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    const Divider(height: 24),
                    ScoreRow(label: '총점', value: data.overall),
                  ],
                ),
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const Text('상세 점수를 불러오지 못했어요.'),
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle(title: '리뷰'),
            const SizedBox(height: 12),
            reviews.when(
              data: (items) => Column(
                children: items
                    .map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ReviewCard(review: review),
                      ),
                    )
                    .toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text('리뷰를 불러오지 못했어요.'),
            ),
            const SizedBox(height: 24),
            WriteChickenReviewButton(
              onPressed: ranking == null
                  ? null
                  : () {
                      final uri = Uri(
                        path: '/review/select-store',
                        queryParameters: {
                          'brandId': ranking!.brandId,
                          'brandName': ranking!.brandName,
                          'menuName': ranking!.menuName,
                        },
                      );
                      context.push(uri.toString());
                    },
              text: '이 치킨 먹은 지점 선택하고 리뷰 남기기',
            ),
          ],
        ),
      ),
    );
  }
}
