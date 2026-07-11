import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/features/toy_list/domain/entities/toy.dart';
import 'package:toy_app/features/toy_list/presentation/views/widgets/toy_card.dart';

void main() {
  const toy = Toy(
    id: '1',
    name: 'Sample Toy',
    description: 'A sample toy',
    price: 15.99,
    imageUrl: 'https://example.com/image.png',
    brand: 'Lego',
    ageGroup: '3-5',
    gender: 'boy',
  );

  testWidgets('renders ToyCard details and responds to tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ToyCard(
          toy: toy,
          onTap: () => tapped = true,
        ),
      ),
    ));

    expect(find.text('Sample Toy'), findsOneWidget);
    expect(find.text('\$15.99'), findsOneWidget);
    expect(find.text('Lego'), findsOneWidget);

    await tester.tap(find.byType(ToyCard));
    expect(tapped, isTrue);
  });
}
