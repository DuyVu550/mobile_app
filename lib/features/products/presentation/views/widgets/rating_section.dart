import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/controllers/auth_providers.dart';
import '../../controllers/review_providers.dart';

class RatingSection extends ConsumerWidget {
  final String productId;
  const RatingSection({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsProvider(productId));
    final authState = ref.watch(authStateProvider);
    final currentUid = authState.valueOrNull?.uid;

    return reviewsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (reviews) {
        final count = reviews.length;
        final avg = count == 0
            ? 0.0
            : reviews
                    .map((r) => (r['rating'] as num).toDouble())
                    .reduce((a, b) => a + b) /
                count;
        final userRating = currentUid == null
            ? null
            : (reviews
                      .where((r) => r['uid'] == currentUid)
                      .firstOrNull?['rating'] as num?)
                    ?.toInt();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 24),
            Text(
              'Đánh giá sản phẩm',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  avg.toStringAsFixed(1),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  '($count đánh giá)',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (currentUid == null)
              Text(
                'Đăng nhập để đánh giá',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              )
            else
              Row(
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: Icon(
                      star <= (userRating ?? 0)
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () =>
                        submitReview(ref, productId, currentUid, star),
                  );
                }),
              ),
          ],
        );
      },
    );
  }
}
