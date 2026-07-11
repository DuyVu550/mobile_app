import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/features/toy_list/domain/entities/toy.dart';
import 'package:toy_app/features/toy_list/domain/entities/brand.dart';
import 'package:toy_app/features/toy_list/presentation/controllers/toy_list_notifier.dart';
import 'package:toy_app/features/toy_list/presentation/controllers/toy_list_state.dart';
import 'package:toy_app/features/toy_list/presentation/views/toy_list_screen.dart';

class MockToyListNotifier extends ToyListNotifier {
  final ToyListState _state;
  MockToyListNotifier(this._state);

  @override
  ToyListState build() => _state;
}

void main() {
  const toy = Toy(
    id: 't1',
    name: 'Lego Spaceship',
    description: 'Description',
    price: 29.99,
    imageUrl: 'image_spaceship',
    brand: 'Lego',
    ageGroup: '3-5',
    gender: 'unisex',
  );

  const brand = Brand(
    id: 'b1',
    name: 'Lego',
    imageUrl: 'logo_lego',
  );

  testWidgets('renders horizontal sections when filters are empty', (tester) async {
    // Set a large screen size so all sections are built and visible
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          toyListNotifierProvider.overrideWith(() => MockToyListNotifier(const ToyListState.success([toy]))),
          brandsListProvider.overrideWithValue(const [brand]),
          ageGroupOptionsProvider.overrideWithValue(const ['3-5']),
          genderOptionsProvider.overrideWithValue(const ['unisex']),
          selectedBrandSectionProvider.overrideWith((ref) => 'Lego'),
          selectedAgeSectionProvider.overrideWith((ref) => '3-5'),
          selectedGenderSectionProvider.overrideWith((ref) => 'unisex'),
        ],
        child: const MaterialApp(
          home: ToyListScreen(),
        ),
      ),
    );

    await tester.pump();

    // Check that section headers are present
    expect(find.text('Mua theo thương hiệu'), findsOneWidget);
    expect(find.text('Phân loại theo độ tuổi'), findsOneWidget);
    expect(find.text('Dành riêng cho bé'), findsOneWidget);
    expect(find.text('Gợi ý cho bạn'), findsOneWidget);
  });
}
