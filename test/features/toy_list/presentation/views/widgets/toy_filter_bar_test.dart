import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/features/toy_list/presentation/views/widgets/toy_filter_bar.dart';
import 'package:toy_app/features/toy_list/presentation/controllers/toy_list_notifier.dart';
import 'package:toy_app/features/toy_list/domain/entities/brand.dart';

void main() {
  testWidgets('ToyFilterBar renders circular brand items', (tester) async {
    final mockBrands = [
      const Brand(id: 'b1', name: 'Lego', imageUrl: 'https://lego.com/logo.png'),
      const Brand(id: 'b2', name: 'Bandai', imageUrl: 'https://bandai.com/logo.png'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          brandsListProvider.overrideWithValue(mockBrands),
          ageGroupOptionsProvider.overrideWithValue([]),
          genderOptionsProvider.overrideWithValue([]),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ToyFilterBar(),
          ),
        ),
      ),
    );

    expect(find.text('Lego'), findsOneWidget);
    expect(find.text('Bandai'), findsOneWidget);
    expect(find.byType(ClipOval), findsNWidgets(2));
  });
}
