import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/core/providers/firebase_providers.dart';
import 'package:toy_app/features/products/presentation/views/category_admin_screen.dart';

Widget wrap(Widget child, FakeFirebaseFirestore firestore) => ProviderScope(
      overrides: [
        firestoreProvider.overrideWithValue(firestore),
      ],
      child: MaterialApp(home: child),
    );

void main() {
  testWidgets('CategoryAdminScreen lists categories and filters by search',
      (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('categories').add({'name': 'Điện thoại'});
    await firestore.collection('categories').add({'name': 'Laptop'});

    await tester.pumpWidget(wrap(const CategoryAdminScreen(), firestore));
    await tester.pumpAndSettle();

    expect(find.text('Điện thoại'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'laptop');
    await tester.pump();

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Điện thoại'), findsNothing);
  });
}
