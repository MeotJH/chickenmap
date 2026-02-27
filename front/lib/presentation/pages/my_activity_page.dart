import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/core/constants/app_sizes.dart';
import 'package:front/presentation/providers/review_providers.dart';
import 'package:front/presentation/widgets/review_card.dart';
import 'package:go_router/go_router.dart';

// 내 활동(리뷰)을 보여주는 화면이다.
class MyActivityPage extends ConsumerWidget {
  const MyActivityPage({super.key});

  @override
  // 내 리뷰 리스트를 표시한다.
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(myReviewsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('내 활동')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: reviews.when(
          data: (items) => ListView.separated(
            itemBuilder: (context, index) {
              final review = items[index];
              return GestureDetector(
                onTap: () =>
                    context.push('/review/${review.id}', extra: review),
                child: ReviewCard(review: review),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: items.length,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('리뷰를 불러오지 못했어요.')),
        ),
      ),
    );
  }
}
