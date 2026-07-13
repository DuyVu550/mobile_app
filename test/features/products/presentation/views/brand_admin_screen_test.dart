import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/core/providers/firebase_providers.dart';
import 'package:toy_app/features/products/presentation/views/brand_admin_screen.dart';

Widget wrap(Widget child, FakeFirebaseFirestore firestore) => ProviderScope(
      overrides: [
        firestoreProvider.overrideWithValue(firestore),
      ],
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('BrandAdminScreen lists brands and filters by search', (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('brands').add({
      'name': 'Samsung',
      'logoUrl': 'https://example.com/samsung.png',
    });
    await firestore.collection('brands').add({
      'name': 'Apple',
      'logoUrl': 'https://example.com/apple.png',
    });

    await tester.pumpWidget(wrap(const BrandAdminScreen(), firestore));
    await tester.pumpAndSettle();

    expect(find.text('Samsung'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Samsung'), findsNothing);
  });
}
