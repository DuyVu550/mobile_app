import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/core/providers/firebase_providers.dart';
import 'package:toy_app/features/products/presentation/views/product_add_edit_screen.dart';

Widget wrap(Widget child, FakeFirebaseFirestore firestore) => ProviderScope(
      overrides: [
        firestoreProvider.overrideWithValue(firestore),
      ],
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('ProductAddEditScreen renders form fields and saves product', (tester) async {
    final firestore = FakeFirebaseFirestore();
    // Seed categories so dropdown has values
    await firestore.collection('categories').add({'name': 'Điện thoại'});
    // Seed brands so dropdown has values
    await firestore.collection('brands').add({'name': 'Samsung'});
    // Seed the product to update
    await firestore.collection('products').doc('s24-id').set({
      'name': 'Galaxy S24',
      'description': 'Samsung Galaxy S24',
      'price': 15000000.0,
      'category': 'Điện thoại',
      'brand': 'Samsung',
      'imageUrl': 'https://example.com/s24.png',
    });

    await tester.pumpWidget(wrap(const ProductAddEditScreen(
      productId: 's24-id',
      productData: {
        'name': 'Galaxy S24',
        'description': 'Samsung Galaxy S24',
        'price': 15000000.0,
        'category': 'Điện thoại',
        'brand': 'Samsung',
        'imageUrl': 'https://example.com/s24.png',
      },
    ), firestore));
    await tester.pumpAndSettle();

    // Verify form text fields are rendered
    expect(find.text('CHỈNH SỬA SẢN PHẨM'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Tên sản phẩm'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Mô tả chi tiết'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Giá sản phẩm (đ)'), findsOneWidget);

    // Submit form
    final saveButton = find.text('LƯU SẢN PHẨM');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Check if added/updated in firestore
    final products = await firestore.collection('products').get();
    expect(products.docs.length, 1);
    expect(products.docs.first.data()['name'], 'Galaxy S24');
  });
}
