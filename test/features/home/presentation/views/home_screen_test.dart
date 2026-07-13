import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:toy_app/features/home/presentation/views/home_screen.dart';
import 'package:toy_app/features/products/presentation/controllers/product_list_notifier.dart';
import 'package:toy_app/features/products/domain/entities/product.dart';
import 'package:toy_app/features/products/domain/repositories/product_repository.dart';
import 'package:toy_app/features/products/presentation/views/widgets/featured_product_slider.dart';
import 'package:toy_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:toy_app/features/auth/domain/entities/app_user.dart';

class FakeProductRepository implements ProductRepository {
  @override
  Stream<Either<String, List<Product>>> watchProducts() {
    return Stream.value(const Right([
      Product(
        id: 'p1',
        name: 'Điện thoại iPhone',
        description: 'Mô tả',
        price: 15000000.0,
        imageUrl: 'iphone.png',
        category: 'Điện thoại',
        isFeatured: true,
        rating: 4.8,
        hasPromotion: true,
      ),
      Product(
        id: 'p2',
        name: 'Laptop MacBook',
        description: 'Mô tả',
        price: 40000000.0,
        imageUrl: 'macbook.png',
        category: 'Laptop',
        isFeatured: false,
        rating: 4.5,
        hasPromotion: false,
      ),
    ]));
  }
}

class FakeAppUser extends AppUser {
  const FakeAppUser()
      : super(
          uid: 'uid123',
          email: 'user@test.com',
          displayName: 'Test User',
        );
}

void main() {
  testWidgets(
      'HomeScreen renders search input, categories tabs, featured slider, and products list',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(FakeProductRepository()),
          categoriesProvider.overrideWith((ref) => Stream.value(['Tất cả', 'Điện thoại', 'Laptop'])),
          authStateProvider.overrideWith((ref) => Stream.value(const FakeAppUser())),
          userProfileProvider.overrideWith((ref) => Stream.value({'role': 'customer'})),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial load: chờ stream nạp dữ liệu.
    await tester.pumpAndSettle();

    // Verify Search & Category Tab items exist
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('Điện thoại'), findsWidgets);
    expect(find.text('Laptop'), findsWidgets);

    // Default tab is 'Tất cả' -> Featured slider and all products visible
    expect(find.byType(FeaturedProductSlider), findsOneWidget);
    expect(find.text('Điện thoại iPhone'), findsWidgets);
    expect(find.text('Laptop MacBook'), findsWidgets);

    // Tap on 'Laptop' tab ChoiceChip
    await tester.tap(find.widgetWithText(ChoiceChip, 'Laptop'));
    await tester.pumpAndSettle();

    // Now in Laptop tab: Featured slider is hidden, only Laptop MacBook is shown
    expect(find.byType(FeaturedProductSlider), findsNothing);
    expect(find.text('Laptop MacBook'), findsWidgets);
    expect(find.text('Điện thoại iPhone'), findsNothing);
  });
}
