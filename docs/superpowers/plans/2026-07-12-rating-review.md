# Product Rating & Review Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow authenticated users to rate products (1–5★), calculating the average rating client-side, and display it at the bottom of the Product Detail screen.

**Architecture:** Firestore subcollection `products/{productId}/reviews/{userId}`. Realtime streaming of reviews to calculate avg/count client-side. Simple Provider & ConsumerWidget implementation.

**Tech Stack:** Flutter, Riverpod, Cloud Firestore.

## Global Constraints
- Do not add any new packages.
- Always run the tests to verify correctness: `flutter test`
- Write clear unit/widget tests for new components.

---

### Task 1: Create Review Providers

**Files:**
- Create: `lib/features/products/presentation/controllers/review_providers.dart`

**Interfaces:**
- Consumes: `firestoreProvider`
- Produces:
  - `reviewsProvider(String productId)` -> `StreamProvider.family<List<Map<String, dynamic>>, String>`
  - `submitReview(WidgetRef ref, String productId, String uid, int rating)` -> `Future<void>`

- [ ] **Step 1: Write review_providers.dart**
  Create `lib/features/products/presentation/controllers/review_providers.dart`:
  ```dart
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
  ```

- [ ] **Step 2: Commit**
  ```bash
  git add lib/features/products/presentation/controllers/review_providers.dart
  git commit -m "feat: add reviewsProvider and submitReview function"
  ```

---

### Task 2: Implement RatingSection Widget with Widget Tests (TDD)

**Files:**
- Create: `lib/features/products/presentation/views/widgets/rating_section.dart`
- Create: `test/features/products/presentation/views/widgets/rating_section_test.dart`

**Interfaces:**
- Consumes: `reviewsProvider`, `authStateProvider`
- Produces: `RatingSection({required String productId})` -> `ConsumerWidget`

- [ ] **Step 1: Write a failing test for RatingSection**
  Create `test/features/products/presentation/views/widgets/rating_section_test.dart`:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:toy_app/features/products/presentation/controllers/review_providers.dart';
  import 'package:toy_app/features/products/presentation/views/widgets/rating_section.dart';

  Widget wrap(Widget child, List<Override> overrides) => ProviderScope(
        overrides: overrides,
        child: MaterialApp(home: Scaffold(body: child)),
      );

  void main() {
    testWidgets('shows Login prompt when user is not authenticated',
        (tester) async {
      await tester.pumpWidget(wrap(
        const RatingSection(productId: 'p1'),
        [
          reviewsProvider.overrideWith((ref, _) => Stream.value([])),
        ],
      ));
      await tester.pump();
      expect(find.text('Đăng nhập để đánh giá'), findsOneWidget);
    });

    testWidgets('renders correct average rating and review count',
        (tester) async {
      final reviews = <Map<String, dynamic>>[
        {'uid': 'u1', 'rating': 4},
        {'uid': 'u2', 'rating': 2},
      ];
      await tester.pumpWidget(wrap(
        const RatingSection(productId: 'p1'),
        [
          reviewsProvider.overrideWith((ref, _) => Stream.value(reviews)),
        ],
      ));
      await tester.pump();
      expect(find.textContaining('3.0'), findsOneWidget);
      expect(find.textContaining('2'), findsOneWidget);
    });
  }
  ```

- [ ] **Step 2: Verify test fails**
  Run: `flutter test test/features/products/presentation/views/widgets/rating_section_test.dart`
  Expected: Failure (rating_section.dart not found or won't compile).

- [ ] **Step 3: Implement RatingSection widget**
  Create `lib/features/products/presentation/views/widgets/rating_section.dart`:
  ```dart
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
  ```

- [ ] **Step 4: Verify test passes**
  Run: `flutter test test/features/products/presentation/views/widgets/rating_section_test.dart`
  Expected: PASS.

- [ ] **Step 5: Commit**
  ```bash
  git add lib/features/products/presentation/views/widgets/rating_section.dart test/features/products/presentation/views/widgets/rating_section_test.dart
  git commit -m "feat: add RatingSection widget and tests"
  ```

---

### Task 3: Integrate RatingSection into ProductDetailScreen & Update Detail Tests

**Files:**
- Modify: `lib/features/products/presentation/views/product_detail_screen.dart`
- Modify: `test/features/products/presentation/views/product_detail_screen_test.dart`
- Modify: `test/features/products/presentation/views/widgets/featured_product_slider_test.dart`

- [ ] **Step 1: Modify ProductDetailScreen**
  Change it to extend `ConsumerWidget` and add `RatingSection(productId: product.id)` at the bottom of the Column.

- [ ] **Step 2: Update existing product detail tests**
  Provide `ProviderScope` and override `reviewsProvider` in:
  - `test/features/products/presentation/views/product_detail_screen_test.dart`
  - `test/features/products/presentation/views/widgets/featured_product_slider_test.dart` (also pump navigation route properly).

- [ ] **Step 3: Run the entire test suite**
  Run: `flutter test`
  Expected: All 46 tests PASS.

- [ ] **Step 4: Commit**
  ```bash
  git add lib/features/products/presentation/views/product_detail_screen.dart test/features/products/presentation/views/product_detail_screen_test.dart test/features/products/presentation/views/widgets/featured_product_slider_test.dart
  git commit -m "feat: integrate RatingSection into ProductDetailScreen and update tests"
  ```
