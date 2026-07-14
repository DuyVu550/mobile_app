import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FeedbackService(firestore);
});

final allFeedbacksProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(feedbackServiceProvider).watchAllFeedbacks();
});

class FeedbackService {
  final FirebaseFirestore _firestore;

  FeedbackService(this._firestore);

  Future<void> submitFeedback({
    required String userId,
    required String userEmail,
    required String type,
    required String content,
    int? rating,
  }) async {
    await _firestore.collection('feedbacks').add({
      'userId': userId,
      'userEmail': userEmail,
      'type': type,
      'content': content,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchAllFeedbacks() {
    return _firestore
        .collection('feedbacks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }
}
