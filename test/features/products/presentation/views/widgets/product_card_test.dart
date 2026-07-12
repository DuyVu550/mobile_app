import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/features/products/domain/entities/product.dart';
import 'package:toy_app/features/products/presentation/views/widgets/product_card.dart';

void main() {
  testWidgets('ProductCard renders product details', (tester) async {
    const product = Product(
      id: 'p1',
      name: 'Điện thoại iPhone 15',
      description: 'iPhone 15 Pro Max',
      price: 25000000.0,
      imageUrl: 'iphone15.png',
      category: 'Điện thoại',
      isFeatured: false,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductCard(product: product),
        ),
      ),
    );

    expect(find.text('Điện thoại iPhone 15'), findsOneWidget);
    expect(find.text('Điện thoại'), findsOneWidget);
    expect(find.text('25.000.000đ'), findsOneWidget);
  });
}
