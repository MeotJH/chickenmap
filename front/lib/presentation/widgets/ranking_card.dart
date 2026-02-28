import 'package:flutter/material.dart';
import 'package:front/core/constants/app_colors.dart';
import 'package:front/core/constants/app_sizes.dart';
import 'package:front/core/utils/formatters.dart';
import 'package:front/domain/entities/brand_menu_ranking.dart';
import 'package:front/presentation/widgets/rating_badge.dart';

const _rankingDefaultImageAsset = 'assets/chicken_default.png';

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
                  child: _NetworkImageWithFallback(
                    imageUrl: ranking.imageUrl,
                    fallbackAssetPath: _rankingDefaultImageAsset,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          rankIndex == 0 ? AppColors.primary : Colors.black87,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '#${rankIndex + 1} Overall',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
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
                        backgroundImage: ranking.brandLogoUrl.trim().isEmpty
                            ? null
                            : NetworkImage(ranking.brandLogoUrl),
                        backgroundColor: Colors.white,
                        onBackgroundImageError:
                            ranking.brandLogoUrl.trim().isEmpty
                                ? null
                                : (_, __) {},
                        child: ranking.brandLogoUrl.trim().isEmpty
                            ? const Icon(
                                Icons.restaurant,
                                size: 14,
                                color: AppColors.textSecondary,
                              )
                            : null,
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

class _NetworkImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final String fallbackAssetPath;
  final double height;
  final double width;
  final BoxFit fit;

  const _NetworkImageWithFallback({
    required this.imageUrl,
    required this.fallbackAssetPath,
    required this.height,
    required this.width,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();
    if (url.isEmpty) {
      return _buildImageFrame(
        Image.asset(
          fallbackAssetPath,
          fit: BoxFit.contain,
        ),
      );
    }
    return _buildImageFrame(
      Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          fallbackAssetPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildImageFrame(Widget image) {
    final squareSize = (height - 28).clamp(120.0, height);
    return Container(
      height: height,
      width: width,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      alignment: Alignment.center,
      child: SizedBox.square(
        dimension: squareSize,
        child: image,
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
        Icon(Icons.thumb_up,
            size: 14, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          '$label ${RatingFormatter.score(value)}',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
