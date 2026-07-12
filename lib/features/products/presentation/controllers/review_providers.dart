import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';

/// Stream reviews for a product in realtime.
final reviewsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, productId) => ref
      .watch(firestoreProvider)
      .collection('products/$productId/reviews')
      .snapshots()
      .map((s) => s.docs
          .map((d) => <String, dynamic>{'uid': d.id, ...d.data()})
          .toList()),
);

/// Submit or update a user review (uses UID as document ID to overwrite).
Future<void> submitReview(
  WidgetRef ref,
  String productId,
  String uid,
  int rating,
) =>
    ref.read(firestoreProvider).doc('products/$productId/reviews/$uid').set({
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
