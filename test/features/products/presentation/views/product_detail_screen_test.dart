import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/features/products/domain/entities/product.dart';
import 'package:toy_app/features/products/presentation/views/product_detail_screen.dart';

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
      const MaterialApp(
        home: ProductDetailScreen(product: product),
      ),
    );

    // Tên hiển thị cả ở AppBar và trong nội dung.
    expect(find.text('iPhone 15 Pro'), findsWidgets);
    expect(find.text('Điện thoại'), findsOneWidget);
    expect(find.text('25000000đ'), findsOneWidget);
    expect(find.text('Điện thoại cao cấp của Apple'), findsOneWidget);
  });
}
