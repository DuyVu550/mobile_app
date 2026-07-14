import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/feedback_service.dart';

class FeedbackAdminScreen extends ConsumerWidget {
  const FeedbackAdminScreen({super.key});

  String _formatDateTime(dynamic rawCreated) {
    if (rawCreated is Timestamp) {
      final date = rawCreated.toDate();
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} ${date.day}/${date.month}/${date.year}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbacksAsync = ref.watch(allFeedbacksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phản hồi từ người dùng'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: feedbacksAsync.when(
        data: (feedbacks) {
          if (feedbacks.isEmpty) {
            return const Center(
              child: Text(
                'Không có phản hồi nào.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final fb = feedbacks[index];
              final type = fb['type'] as String? ?? 'Góp ý';
              final content = fb['content'] as String? ?? '';
              final email = fb['userEmail'] as String? ?? 'Ẩn danh';
              final dateStr = _formatDateTime(fb['createdAt']);
              final rating = fb['rating'] as int?;

              Color tagColor = Colors.green;
              if (type == 'Báo lỗi') {
                tagColor = Colors.redAccent;
              } else if (type == 'Đánh giá ứng dụng') {
                tagColor = Colors.amber.shade800;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              email,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: tagColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: tagColor, width: 1),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                color: tagColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (rating != null) ...[
                            const SizedBox(width: 12),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        content,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi tải phản hồi: $err')),
      ),
    );
  }
}
