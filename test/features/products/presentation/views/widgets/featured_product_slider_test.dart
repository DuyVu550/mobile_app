import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/features/products/domain/entities/product.dart';
import 'package:toy_app/features/products/presentation/controllers/review_providers.dart';
import 'package:toy_app/features/products/presentation/views/product_detail_screen.dart';
import 'package:toy_app/features/products/presentation/views/widgets/featured_product_slider.dart';

void main() {
  testWidgets(
      'FeaturedProductSlider renders products and detail page navigation',
      (tester) async {
    final List<Product> products = [
      const Product(
        id: 'p1',
        name: 'iPhone 15',
        description: 'Desc',
        price: 20000000.0,
        imageUrl: 'iphone15.png',
        category: 'Điện thoại',
        isFeatured: true,
        rating: 4.5,
        hasPromotion: false,
      ),
      const Product(
        id: 'p2',
        name: 'MacBook Pro',
        description: 'Desc',
        price: 40000000.0,
        imageUrl: 'macbook.png',
        category: 'Laptop',
        isFeatured: true,
        rating: 4.7,
        hasPromotion: true,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reviewsProvider.overrideWith((ref, _) => Stream.value([])),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: FeaturedProductSlider(products: products),
          ),
        ),
      ),
    );

    expect(find.text('iPhone 15'), findsOneWidget);
    expect(find.text('20000000đ'), findsOneWidget);

    await tester.tap(find.text('iPhone 15'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300)); // Complete route transition animation

    expect(find.byType(ProductDetailScreen), findsOneWidget);
  });
}
