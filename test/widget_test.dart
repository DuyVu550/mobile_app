import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:toy_app/core/providers/firebase_providers.dart';
import 'package:toy_app/features/toy_list/presentation/views/toy_list_screen.dart';

/// Seed 3 sản phẩm mẫu vào Firestore giả để test luồng realtime + tìm kiếm.
Future<FakeFirebaseFirestore> seededFirestore() async {
  final firestore = FakeFirebaseFirestore();
  final toys = firestore.collection('toys');
  await toys.doc('toy-01').set({
    'name': 'Teddy Bear XL',
    'description': 'A soft and huggable giant teddy bear.',
    'price': 25.99,
    'imageUrl': 'https://picsum.photos/200',
    'brand': 'Fisher-Price',
    'ageGroup': '3-5',
    'gender': 'unisex',
    'color': 'brown',
  });
  await toys.doc('toy-02').set({
    'name': 'Lego City Police Station',
    'description': 'Construct your own city police department.',
    'price': 49.99,
    'imageUrl': 'https://picsum.photos/200',
    'brand': 'Lego',
    'ageGroup': '6-8',
    'gender': 'unisex',
    'color': 'blue',
  });
  await toys.doc('toy-03').set({
    'name': 'RC Racing Car',
    'description': 'High speed remote control car.',
    'price': 34.50,
    'imageUrl': 'https://picsum.photos/200',
    'brand': 'Hot Wheels',
    'ageGroup': '6-8',
    'gender': 'boy',
    'color': 'red',
  });
  return firestore;
}

void main() {
  Widget harness(FakeFirebaseFirestore firestore) => ProviderScope(
        overrides: [firestoreProvider.overrideWithValue(firestore)],
        child: const MaterialApp(home: ToyListScreen()),
      );

  // Fake Firestore stream cần vài chu kỳ microtask để phát dữ liệu.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('hiển thị realtime + tìm kiếm theo tên', (tester) async {
    tester.view.physicalSize = const Size(1200, 2500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final firestore = await seededFirestore();
    await tester.pumpWidget(harness(firestore));
    // Không dùng pumpAndSettle: FeaturedToySlider có Timer.periodic chạy mãi.
    await settle(tester);

    // 3 sản phẩm hiển thị (toy đầu cũng nằm trong slider nên dùng findsWidgets).
    expect(find.text('Teddy Bear XL'), findsWidgets);
    expect(find.text('Lego City Police Station'), findsWidgets);
    expect(find.text('RC Racing Car'), findsWidgets);

    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // Tìm 'Teddy' -> chỉ còn Teddy Bear.
    await tester.enterText(searchField, 'Teddy');
    await tester.pump();
    expect(find.text('Teddy Bear XL'), findsWidgets);
    expect(find.text('Lego City Police Station'), findsNothing);
    expect(find.text('RC Racing Car'), findsNothing);

    // Tìm 'xyz' -> danh sách rỗng.
    await tester.enterText(searchField, 'xyz');
    await tester.pump();
    expect(find.text('Không tìm thấy đồ chơi nào.'), findsOneWidget);

    // Xóa từ khóa -> khôi phục cả 3.
    await tester.enterText(searchField, '');
    await tester.pump();
    expect(find.text('Teddy Bear XL'), findsWidgets);
    expect(find.text('Lego City Police Station'), findsWidgets);
    expect(find.text('RC Racing Car'), findsWidgets);

    // Dọn Timer của slider để test kết thúc sạch.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('collection rỗng -> hiển thị thông báo không có sản phẩm',
      (tester) async {
    await tester.pumpWidget(harness(FakeFirebaseFirestore()));
    await settle(tester);

    expect(find.text('Không tìm thấy đồ chơi nào.'), findsOneWidget);
  });
}
