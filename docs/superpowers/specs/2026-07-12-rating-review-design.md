# Design Specification: Product Rating & Review

This document defines the design and architecture for the Product Rating & Review feature.

## 1. Overview
Authenticated users can submit a rating of 1 to 5 stars for any product.
- Each user can only submit one rating per product. If they submit a new rating, it overrides their previous one.
- Anyone (including unauthenticated guests) can view the average rating and the total count of reviews for a product.
- The rating widget is displayed at the bottom of the `ProductDetailScreen`, below the technical specifications table.

---

## 2. Data Model & Storage

We will store reviews under a subcollection of the product document in Cloud Firestore:
`products/{productId}/reviews/{userId}`

Using the user's UID as the document ID guarantees that each user can only have one rating per product. Updating a rating will perform a `set()` operation on the same path, overwriting the previous value.

### Fields:
- `rating`: `int` (range: 1 to 5)
- `createdAt`: `Timestamp` (FieldValue.serverTimestamp())

### Firestore Security Rules:
```javascript
match /products/{productId}/reviews/{uid} {
  allow read: if true;
  allow write: if request.auth != null && request.auth.uid == uid;
}
```

---

## 3. Architecture & Data Flow

To align with the `ponytail` skill (the simplest, cleanest solution that works), we will avoid adding redundant use cases or complex repositories:
1. **Riverpod Providers**:
   - `reviewsProvider(productId)`: A `StreamProvider.family` that listens to `products/{productId}/reviews` and returns a list of maps containing the reviews.
   - `submitReview`: A helper function that saves the review to Cloud Firestore.
2. **User Interface**:
   - `RatingSection`: A `ConsumerWidget` that reads `reviewsProvider` and `authStateProvider` to calculate and render:
     - The average rating (e.g. `★ 4.5`).
     - The total review count (e.g. `(12 đánh giá)`).
     - Tap-to-rate stars if authenticated, or a prompt to log in if unauthenticated.
   - `ProductDetailScreen`: Updated to include the `RatingSection` at the bottom of the scrollable column.

---

## 4. Detailed Component Design

### 4.1 Riverpod Providers
File: `lib/features/products/presentation/controllers/review_providers.dart`

```dart
final reviewsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, productId) {
  return ref.watch(firestoreProvider)
      .collection('products/$productId/reviews')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => {'uid': doc.id, ...doc.data()})
          .toList());
});

Future<void> submitReview(
  WidgetRef ref,
  String productId,
  String uid,
  int rating,
) {
  return ref.read(firestoreProvider)
      .doc('products/$productId/reviews/$uid')
      .set({
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
      });
}
```

### 4.2 RatingSection Widget
File: `lib/features/products/presentation/views/widgets/rating_section.dart`

- Displays a title "Đánh giá sản phẩm".
- Displays average star rating and review count.
- If the user is logged in (i.e. `authStateProvider` returns a user), displays 5 interactive star icons. Tapping a star calls `submitReview`.
- If the user is not logged in, displays "Đăng nhập để đánh giá".

---

## 5. Verification Plan

### Automated Tests
We will add widget tests to `test/features/products/presentation/views/widgets/rating_section_test.dart` to verify:
1. RatingSection shows "Đăng nhập để đánh giá" when unauthenticated.
2. RatingSection shows the correct average rating (e.g. `3.0`) and count (e.g. `2`) when reviews are loaded.
3. RatingSection highlights the stars representing the current user's submitted rating.

### Manual Verification
1. Launch the app and sign in.
2. Navigate to a product detail page.
3. Rate the product 4 stars. Verify the stars update, and the average rating reflects the new rating.
4. Sign out, visit the same product page, and verify the rating stars are replaced with the login prompt.
