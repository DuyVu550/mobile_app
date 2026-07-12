import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toy_app/features/products/presentation/controllers/review_providers.dart';
import 'package:toy_app/features/products/presentation/views/widgets/rating_section.dart';

Widget wrap(Widget child, List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  testWidgets('shows Login prompt when user is not authenticated',
      (tester) async {
    await tester.pumpWidget(wrap(
      const RatingSection(productId: 'p1'),
      [
        reviewsProvider.overrideWith((ref, _) => Stream.value([])),
      ],
    ));
    await tester.pump();
    expect(find.text('Đăng nhập để đánh giá'), findsOneWidget);
  });

  testWidgets('renders correct average rating and review count',
      (tester) async {
    final reviews = <Map<String, dynamic>>[
      {'uid': 'u1', 'rating': 4},
      {'uid': 'u2', 'rating': 2},
    ];
    await tester.pumpWidget(wrap(
      const RatingSection(productId: 'p1'),
      [
        reviewsProvider.overrideWith((ref, _) => Stream.value(reviews)),
      ],
    ));
    await tester.pump();
    expect(find.textContaining('3.0'), findsOneWidget);
    expect(find.textContaining('2'), findsOneWidget);
  });
}
