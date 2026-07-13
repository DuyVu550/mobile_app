import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/core/providers/firebase_providers.dart';
import 'package:toy_app/features/products/presentation/views/product_admin_screen.dart';

Widget wrap(Widget child, FakeFirebaseFirestore firestore) => ProviderScope(
      overrides: [
        firestoreProvider.overrideWithValue(firestore),
      ],
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('ProductAdminScreen lists products and filters by search', (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('products').add({
      'name': 'iPhone 15',
      'price': 20000000.0,
      'category': 'Điện thoại',
      'imageUrl': 'https://example.com/iphone.png',
      'description': 'Apple iPhone 15',
      'isFeatured': true,
      'hasPromotion': false,
    });
    await firestore.collection('products').add({
      'name': 'MacBook Pro',
      'price': 40000000.0,
      'category': 'Laptop',
      'imageUrl': 'https://example.com/macbook.png',
      'description': 'Apple MacBook Pro',
      'isFeatured': false,
      'hasPromotion': true,
    });

    await tester.pumpWidget(wrap(const ProductAdminScreen(), firestore));
    await tester.pumpAndSettle();

    expect(find.text('iPhone 15'), findsOneWidget);
    expect(find.text('MacBook Pro'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'macbook');
    await tester.pump();

    expect(find.text('MacBook Pro'), findsOneWidget);
    expect(find.text('iPhone 15'), findsNothing);
  });
}
