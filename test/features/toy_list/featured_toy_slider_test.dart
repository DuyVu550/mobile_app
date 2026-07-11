import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/features/toy_list/domain/entities/toy.dart';
import 'package:toy_app/features/toy_list/presentation/views/widgets/featured_toy_slider.dart';

void main() {
  final toys = [
    const Toy(id: '1', name: 'Toy A', description: 'a', price: 1, imageUrl: 'x'),
    const Toy(id: '2', name: 'Toy B', description: 'b', price: 2, imageUrl: 'y'),
    const Toy(id: '3', name: 'Toy C', description: 'c', price: 3, imageUrl: 'z'),
  ];

  Widget wrap(List<Toy> data) => MaterialApp(
        home: Scaffold(body: FeaturedToySlider(toys: data)),
      );

  testWidgets('danh sách rỗng -> không render gì (SizedBox.shrink)',
      (tester) async {
    await tester.pumpWidget(wrap(const []));
    expect(find.byType(PageView), findsNothing);
  });

  testWidgets('render slide đầu tiên và đủ số chấm chỉ báo', (tester) async {
    await tester.pumpWidget(wrap(toys));
    await tester.pump(); // 1 frame, tránh pumpAndSettle vì Timer chạy mãi

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('Toy A'), findsOneWidget);
    // 3 chấm chỉ báo = 3 AnimatedContainer.
    expect(find.byType(AnimatedContainer), findsNWidgets(3));
  });

  testWidgets('sau 3s tự chuyển sang slide kế tiếp', (tester) async {
    await tester.pumpWidget(wrap(toys));
    await tester.pump();

    expect(find.text('Toy A'), findsOneWidget);

    // Đẩy thời gian qua mốc 3s để Timer.periodic kích hoạt chuyển slide.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500)); // animation chuyển trang

    expect(find.text('Toy B'), findsOneWidget);

    // Dọn Timer để test kết thúc sạch.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('quay vòng về slide đầu sau slide cuối', (tester) async {
    await tester.pumpWidget(wrap(toys));
    await tester.pump();

    // 3 lần x 3s -> A -> B -> C -> A
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(find.text('Toy A'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
