import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/features/products/domain/entities/product.dart';
import 'package:toy_app/features/products/presentation/controllers/review_providers.dart';
import 'package:toy_app/features/products/presentation/views/product_detail_screen.dart';

List<Override> _noReviews() => [
      reviewsProvider.overrideWith((ref, _) => Stream.value([])),
    ];

void main() {
  testWidgets('ProductDetailScreen renders product details', (tester) async {
    const product = Product(
      id: 'p1',
      name: 'iPhone 15 Pro',
      description: 'Điện thoại cao cấp của Apple',
      price: 25000000.0,
      imageUrl: 'iphone15.png',
      category: 'Điện thoại',
      isFeatured: true,
      rating: 4.8,
      hasPromotion: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: _noReviews(),
        child: const MaterialApp(
          home: ProductDetailScreen(product: product),
        ),
      ),
    );
    await tester.pump();

    // Tên hiển thị cả ở AppBar và trong nội dung.
    expect(find.text('iPhone 15 Pro'), findsWidgets);
    expect(find.text('Điện thoại'), findsOneWidget);
    expect(find.text('25000000đ'), findsOneWidget);
    expect(find.text('Điện thoại cao cấp của Apple'), findsOneWidget);
  });

  testWidgets(
      'ProductDetailScreen renders specifications table when specifications are present',
      (tester) async {
    const product = Product(
      id: 'p1',
      name: 'iPhone 15 Pro',
      description: 'Điện thoại cao cấp',
      price: 25000000.0,
      imageUrl: 'iphone15.png',
      category: 'Điện thoại',
      isFeatured: true,
      rating: 4.8,
      hasPromotion: true,
      specifications: {
        'RAM': '8 GB',
        'Bộ nhớ': '128 GB',
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: _noReviews(),
        child: const MaterialApp(
          home: ProductDetailScreen(product: product),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Thông số kỹ thuật'), findsOneWidget);
    expect(find.text('RAM'), findsOneWidget);
    expect(find.text('8 GB'), findsOneWidget);
    expect(find.text('Bộ nhớ'), findsOneWidget);
    expect(find.text('128 GB'), findsOneWidget);
  });

  testWidgets(
      'ProductDetailScreen does not render specifications table when specifications are empty or null',
      (tester) async {
    const product = Product(
      id: 'p1',
      name: 'iPhone 15 Pro',
      description: 'Điện thoại cao cấp',
      price: 25000000.0,
      imageUrl: 'iphone15.png',
      category: 'Điện thoại',
      isFeatured: true,
      rating: 4.8,
      hasPromotion: true,
      specifications: {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: _noReviews(),
        child: const MaterialApp(
          home: ProductDetailScreen(product: product),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Thông số kỹ thuật'), findsNothing);
  });
}
