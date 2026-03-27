import 'package:flutter/material.dart';
import 'package:front/core/constants/app_colors.dart';
import 'package:front/core/utils/formatters.dart';
import 'package:front/domain/entities/review.dart';

// 리뷰 리스트에 쓰는 카드 위젯이다.
class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  // 리뷰 정보를 카드 형태로 렌더링한다.
  Widget build(BuildContext context) {
    final isChickenKing = _isChickenKing(review.userEmail);
    final reviewerName = isChickenKing
        ? '치킨킹'
        : _reviewerDisplayName(review.userEmail);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${review.brandName} · ${review.menuName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isChickenKing)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Special',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                    ),
                  if (isChickenKing) const SizedBox(height: 6),
                  Text(
                    reviewerName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            review.storeName,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, size: 16, color: AppColors.ratingStar),
              const SizedBox(width: 4),
              Text(
                RatingFormatter.score(review.overall),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                '${review.createdAt.year}.${review.createdAt.month}.${review.createdAt.day}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: const TextStyle(fontSize: 13)),
          if (review.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 78,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.imageUrls.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final imageUrl = review.imageUrls[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: () => _openImageViewer(context, imageUrl),
                      child: Image.network(
                        imageUrl,
                        width: 78,
                        height: 78,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 78,
                          height: 78,
                          color: const Color(0xFFF3F4F6),
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isChickenKing(String email) {
    final normalized = email.trim().toLowerCase();
    return normalized == 'marionette934@gmail.com' ||
        normalized == 'businesskim93@gmail.com';
  }

  String _reviewerDisplayName(String email) {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return 'unknown';
    final at = normalized.indexOf('@');
    if (at <= 0) return normalized;
    return normalized.substring(0, at);
  }

  void _openImageViewer(BuildContext context, String imageUrl) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
