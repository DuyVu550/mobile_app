import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/features/home/presentation/views/home_screen.dart';
import 'package:toy_app/features/products/presentation/controllers/product_list_notifier.dart';
import 'package:toy_app/features/products/domain/entities/product.dart';

void main() {
  testWidgets('HomeScreen renders search input and products list',
      (tester) async {
    final mockProducts = [
      const Product(
        id: 'p1',
        name: 'Điện thoại iPhone',
        description: 'Mô tả',
        price: 15000000.0,
        imageUrl: 'iphone.png',
        category: 'Điện thoại',
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
    expect(find.text('Điện thoại iPhone'), findsOneWidget);
  });
}
