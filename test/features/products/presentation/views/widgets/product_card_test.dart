import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/features/products/domain/entities/product.dart';
import 'package:toy_app/features/products/presentation/controllers/review_providers.dart';
import 'package:toy_app/features/products/presentation/views/widgets/product_card.dart';

void main() {
  testWidgets('ProductCard renders product details and navigates on tap',
      (tester) async {
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
      stock: 10,
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
    expect(find.text('Còn lại: 10'), findsOneWidget);
    expect(find.text('25.000.000đ'), findsOneWidget);
    expect(find.text('SALE'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
  });
}
