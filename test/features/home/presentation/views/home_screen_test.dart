import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/features/home/presentation/views/home_screen.dart';
import 'package:toy_app/features/products/presentation/controllers/product_list_notifier.dart';
import 'package:toy_app/features/products/domain/entities/product.dart';
import 'package:toy_app/features/products/presentation/views/widgets/featured_product_slider.dart';

void main() {
  testWidgets(
      'HomeScreen renders search input, featured slider, and products list',
      (tester) async {
    final mockProducts = [
      const Product(
        id: 'p1',
        name: 'Điện thoại iPhone',
        description: 'Mô tả',
        price: 15000000.0,
        imageUrl: 'iphone.png',
        category: 'Điện thoại',
        isFeatured: true,
      ),
      const Product(
        id: 'p2',
        name: 'Laptop MacBook',
        description: 'Mô tả',
        price: 40000000.0,
        imageUrl: 'macbook.png',
        category: 'Laptop',
        isFeatured: false,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          filteredProductsProvider
              .overrideWithValue(AsyncValue.data(mockProducts)),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Tìm kiếm sản phẩm...'), findsOneWidget);
    expect(find.byType(FeaturedProductSlider), findsOneWidget);
    expect(find.text('Điện thoại iPhone'),
        findsWidgets); // Appears in both slider and card
    expect(find.text('Laptop MacBook'),
        findsOneWidget); // Appears only in card
  });
}
