import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/features/toy_list/presentation/views/toy_list_screen.dart';

void main() {
  // Pump ToyListScreen trực tiếp (không qua MyApp/AuthGate) để tránh phụ thuộc Firebase.
  Widget harness() => const ProviderScope(
        child: MaterialApp(home: ToyListScreen()),
      );

  testWidgets('Toy store search functionality test', (WidgetTester tester) async {
    await tester.pumpWidget(harness());

    // Wait for the mock data source delay (800ms) to load the initial list of toys
    await tester.pumpAndSettle();

    // Verify all 3 default mock toys are displayed on load.
    // Lưu ý: toy đầu tiên cũng xuất hiện trong FeaturedToySlider nên có thể >1 widget.
    expect(find.text('Teddy Bear XL'), findsWidgets);
    expect(find.text('Lego City Police Station'), findsWidgets);
    expect(find.text('RC Racing Car'), findsWidgets);

    // Locate the search input field
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // Scenario 1: Search for 'Teddy'
    await tester.enterText(searchField, 'Teddy');
    await tester.pump(); // Trigger onChanged filtering

    // Verify only 'Teddy Bear XL' is displayed
    expect(find.text('Teddy Bear XL'), findsWidgets);
    expect(find.text('Lego City Police Station'), findsNothing);
    expect(find.text('RC Racing Car'), findsNothing);

    // Scenario 2: Search for a query that matches nothing 'xyz'
    await tester.enterText(searchField, 'xyz');
    await tester.pump();

    // Verify empty state is displayed
    expect(find.text('Không tìm thấy đồ chơi nào.'), findsOneWidget);
    expect(find.text('Teddy Bear XL'), findsNothing);

    // Scenario 3: Clear the search query
    await tester.enterText(searchField, '');
    await tester.pump();

    // Verify all 3 toys are restored
    expect(find.text('Teddy Bear XL'), findsWidgets);
    expect(find.text('Lego City Police Station'), findsWidgets);
    expect(find.text('RC Racing Car'), findsWidgets);
  });
}
