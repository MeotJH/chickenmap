import 'package:flutter/material.dart';
import 'package:front/core/constants/app_colors.dart';
import 'package:front/core/constants/app_sizes.dart';
import 'package:front/core/utils/formatters.dart';
import 'package:front/domain/entities/brand_menu_ranking.dart';
import 'package:front/presentation/widgets/rating_badge.dart';

// 랭킹 카드 UI를 표현하는 위젯이다.
class RankingCard extends StatelessWidget {
  final BrandMenuRanking ranking;
  final int rankIndex;
  final VoidCallback onTap;

  const RankingCard({
    super.key,
    required this.ranking,
    required this.rankIndex,
    required this.onTap,
  });

  @override
  // 랭킹 카드의 전체 레이아웃을 그린다.
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.cardRadius),
                  ),
                  child: Image.network(
                    ranking.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: rankIndex == 0 ? AppColors.primary : Colors.black87,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '#${rankIndex + 1} Overall',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: RatingBadge(
                    rating: ranking.rating,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    textColor: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(ranking.brandLogoUrl),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ranking.brandName,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ranking.menuName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _HighlightChip(
                        label: ranking.highlightLabelA,
                        value: ranking.highlightScoreA,
                      ),
                      const SizedBox(width: 10),
                      _HighlightChip(
                        label: ranking.highlightLabelB,
                        value: ranking.highlightScoreB,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${ranking.reviewCount.toString()} Reviews',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      Text(
                        '상세 보기 >',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 랭킹 카드의 하이라이트 항목을 표시하는 칩이다.
class _HighlightChip extends StatelessWidget {
  final String label;
  final double value;

  const _HighlightChip({
    required this.label,
    required this.value,
  });

  @override
  // 하이라이트 항목 텍스트를 배치한다.
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.thumb_up, size: 14, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          '$label ${RatingFormatter.score(value)}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
