import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/features/products/domain/entities/product.dart';
import 'package:toy_app/features/products/domain/repositories/product_repository.dart';
import 'package:toy_app/features/products/presentation/controllers/product_list_notifier.dart';

class FakeProductRepository implements ProductRepository {
  @override
  Stream<Either<String, List<Product>>> watchProducts() {
    return Stream.value(const Right([
      Product(
        id: 'p1',
        name: 'Điện thoại iPhone',
        description: 'iPhone 15 Pro Max',
        price: 25000000.0,
        imageUrl: 'iphone.png',
        category: 'Điện thoại',
        isFeatured: false,
      ),
      Product(
        id: 'p2',
        name: 'Laptop MacBook',
        description: 'MacBook Pro M3',
        price: 45000000.0,
        imageUrl: 'macbook.png',
        category: 'Laptop',
        isFeatured: false,
      ),
    ]));
  }
}

void main() {
  test('ProductListNotifier filters products correctly based on searchQuery',
      () async {
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(FakeProductRepository()),
      ],
    );
    addTearDown(container.dispose);

    // Chờ stream nạp dữ liệu.
    await container
        .read(productListNotifierProvider.notifier)
        .stream
        .firstWhere((s) => s.products.hasValue);

    final allProducts = container.read(filteredProductsProvider).value;
    expect(allProducts?.length, 2);

    // Lọc theo 'iphone'.
    container
        .read(productListNotifierProvider.notifier)
        .updateSearchQuery('iphone');
    final filtered = container.read(filteredProductsProvider).value;
    expect(filtered?.length, 1);
    expect(filtered?.first.name, 'Điện thoại iPhone');

    // Lọc không phân biệt dấu: 'dien thoai' khớp 'Điện thoại'.
    container
        .read(productListNotifierProvider.notifier)
        .updateSearchQuery('dien thoai');
    final filtered2 = container.read(filteredProductsProvider).value;
    expect(filtered2?.length, 1);
    expect(filtered2?.first.name, 'Điện thoại iPhone');
  });

  test('categoriesProvider extracts unique sorted categories with "Tất cả"',
      () async {
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(FakeProductRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(productListNotifierProvider.notifier)
        .stream
        .firstWhere((s) => s.products.hasValue);

    final categories = container.read(categoriesProvider);
    expect(categories, ['Tất cả', 'Laptop', 'Điện thoại']); // Alphabetically sorted
  });

  test('ProductListNotifier filters products by category and searchQuery',
      () async {
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(FakeProductRepository()),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(productListNotifierProvider.notifier)
        .stream
        .firstWhere((s) => s.products.hasValue);

    // Initial state
    expect(
        container.read(productListNotifierProvider).selectedCategory, 'Tất cả');

    // Select category 'Laptop'
    container
        .read(productListNotifierProvider.notifier)
        .selectCategory('Laptop');
    expect(
        container.read(productListNotifierProvider).selectedCategory, 'Laptop');
    var filtered = container.read(filteredProductsProvider).value;
    expect(filtered?.length, 1);
    expect(filtered?.first.name, 'Laptop MacBook');

    // Combine category with search query 'macbook'
    container
        .read(productListNotifierProvider.notifier)
        .updateSearchQuery('macbook');
    filtered = container.read(filteredProductsProvider).value;
    expect(filtered?.length, 1);

    // Combine category 'Laptop' with search query 'iphone' -> should return 0 items
    container
        .read(productListNotifierProvider.notifier)
        .updateSearchQuery('iphone');
    filtered = container.read(filteredProductsProvider).value;
    expect(filtered?.length, 0);
  });
}
