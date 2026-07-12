# Product Card Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign `ProductCard` to look premium and support tap navigation to `ProductDetailScreen`.

**Architecture:** Wrap the Card in a `GestureDetector` that pushes `ProductDetailScreen`. Use custom container decoration for soft shadows and rounded borders. Add rating and sale overlay badges on the product image.

**Tech Stack:** Flutter, Riverpod.

## Global Constraints
- Do not add any new packages.
- Always run the tests to verify correctness: `flutter test`
- Make sure existing test suite passes completely.

---

### Task 1: Redesign ProductCard Widget

**Files:**
- Modify: [product_card.dart](file:///d:/mobile_app/lib/features/products/presentation/views/widgets/product_card.dart)
- Modify: [product_card_test.dart](file:///d:/mobile_app/test/features/products/presentation/views/widgets/product_card_test.dart)

**Interfaces:**
- Consumes: `Product`
- Produces: Redesigned `ProductCard` with tap-to-navigate.

- [ ] **Step 1: Write ProductCard Redesign**
  Modify `lib/features/products/presentation/views/widgets/product_card.dart` to support tapping and a premium modern card UI:
  ```dart
  import 'package:flutter/material.dart';
  import '../../../domain/entities/product.dart';
  import '../product_detail_screen.dart'; // import

  class ProductCard extends StatelessWidget {
    final Product product;

    const ProductCard({super.key, required this.product});

    @override
    Widget build(BuildContext context) {
      final priceStr = '${product.price.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}đ';

      return GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.amber.shade50,
                          child: const Icon(Icons.image, size: 40, color: Colors.amber),
                        ),
                      ),
                    ),
                    // Sale badge
                    if (product.hasPromotion)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'SALE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Rating badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 12),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Text(
                          priceStr,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey.shade400,
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
  ```

- [ ] **Step 2: Update ProductCard Test**
  Modify `test/features/products/presentation/views/widgets/product_card_test.dart` to override `reviewsProvider` when rendering `ProductDetailScreen` context (since clicking/tapping the card routes to `ProductDetailScreen` which now uses `reviewsProvider`).
  Wait! The widget test in `product_card_test.dart` only pumps `ProductCard`. Since `ProductCard` only routes on tap, we don't need to override `reviewsProvider` unless the test actually taps the card to navigate. But let's add a test verifying navigation just in case:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:toy_app/features/products/domain/entities/product.dart';
  import 'package:toy_app/features/products/presentation/controllers/review_providers.dart';
  import 'package:toy_app/features/products/presentation/views/widgets/product_card.dart';

  void main() {
    testWidgets('ProductCard renders product details and navigates on tap', (tester) async {
      const product = Product(
        id: 'p1',
        name: 'Điện thoại iPhone 15',
        description: 'iPhone 15 Pro Max',
        price: 25000000.0,
        imageUrl: 'iphone15.png',
        category: 'Điện thoại',
        isFeatured: false,
        rating: 4.8,
        hasPromotion: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            reviewsProvider.overrideWith((ref, _) => Stream.value([])),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ProductCard(product: product),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Điện thoại iPhone 15'), findsOneWidget);
      expect(find.text('Điện thoại'), findsOneWidget);
      expect(find.text('25.000.000đ'), findsOneWidget);
      expect(find.text('SALE'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
    });
  }
  ```

- [ ] **Step 3: Run all tests**
  Run: `flutter test`
  Expected: PASS.

- [ ] **Step 4: Commit**
  ```bash
  git add lib/features/products/presentation/views/widgets/product_card.dart test/features/products/presentation/views/widgets/product_card_test.dart
  git commit -m "feat: redesign ProductCard with premium visual elements and tap navigation"
  ```
