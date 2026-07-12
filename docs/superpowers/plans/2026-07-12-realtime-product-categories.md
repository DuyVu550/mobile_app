# Real-time Product Categories Tabs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a real-time product category filtering mechanism using ChoiceChips under a horizontal scrollable tab bar, with dynamic category extraction, accent-insensitive search, and conditional Featured Slider visibility.

**Architecture:** Extend Riverpod state (`ProductListState`) to hold the selected category. A dynamic provider (`categoriesProvider`) extracts unique categories. The `filteredProductsProvider` is updated to perform double filtering (search query + category). ChoiceChips are built on the HomeScreen and handle updates via notifier commands.

**Tech Stack:** Flutter, Riverpod, Cloud Firestore, Dart.

## Global Constraints
- Accent-insensitive & case-insensitive matching.
- Dynamic categories list prepended with `'Tất cả'` and sorted alphabetically.
- `FeaturedProductSlider` shown only on `'Tất cả'` tab.
- Native/stdlib styling, no new external packages.

---

### Task 1: Update State and Notifier (Business Logic)

**Files:**
- Modify: `lib/features/products/presentation/controllers/product_list_state.dart`
- Modify: `lib/features/products/presentation/controllers/product_list_notifier.dart`
- Modify: `test/features/products/presentation/controllers/product_list_notifier_test.dart`

**Interfaces:**
- Consumes: `Product` entity and `productListNotifierProvider`.
- Produces: `categoriesProvider` (`Provider<List<String>>`), state updating via `selectCategory(String category)`.

- [ ] **Step 1: Write the failing test**
  Add test cases verifying categories extraction, `selectCategory` updates, and combined filtering.
  Open `test/features/products/presentation/controllers/product_list_notifier_test.dart` and add the following tests to the `main()` group:

  ```dart
  test('categoriesProvider extracts unique sorted categories with "Tất cả"', () async {
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

  test('ProductListNotifier filters products by category and searchQuery', () async {
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
    expect(container.read(productListNotifierProvider).selectedCategory, 'Tất cả');

    // Select category 'Laptop'
    container.read(productListNotifierProvider.notifier).selectCategory('Laptop');
    expect(container.read(productListNotifierProvider).selectedCategory, 'Laptop');
    var filtered = container.read(filteredProductsProvider).value;
    expect(filtered?.length, 1);
    expect(filtered?.first.name, 'Laptop MacBook');

    // Combine category with search query 'macbook'
    container.read(productListNotifierProvider.notifier).updateSearchQuery('macbook');
    filtered = container.read(filteredProductsProvider).value;
    expect(filtered?.length, 1);

    // Combine category 'Laptop' with search query 'iphone' -> should return 0 items
    container.read(productListNotifierProvider.notifier).updateSearchQuery('iphone');
    filtered = container.read(filteredProductsProvider).value;
    expect(filtered?.length, 0);
  });
  ```

- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test test/features/products/presentation/controllers/product_list_notifier_test.dart`
  Expected: Compilation failures or test failures (e.g. `categoriesProvider` / `selectedCategory` not defined).

- [ ] **Step 3: Write minimal implementation**
  Update `lib/features/products/presentation/controllers/product_list_state.dart` to add `selectedCategory` field:

  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../domain/entities/product.dart';

  part 'product_list_state.freezed.dart';

  @freezed
  class ProductListState with _$ProductListState {
    const factory ProductListState({
      @Default('') String searchQuery,
      @Default('Tất cả') String selectedCategory,
      @Default(AsyncValue.loading()) AsyncValue<List<Product>> products,
    }) = _ProductListState;
  }
  ```

  Run build runner to regenerate freezed class:
  Run: `flutter pub run build_runner build --delete-conflicting-outputs`

  Update `lib/features/products/presentation/controllers/product_list_notifier.dart` to implement `selectCategory`, `categoriesProvider` and update `filteredProductsProvider`:

  ```dart
  // Inside ProductListNotifier:
  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  // Add categoriesProvider at the file level:
  final categoriesProvider = Provider<List<String>>((ref) {
    final state = ref.watch(productListNotifierProvider);
    return state.products.maybeWhen(
      data: (products) {
        final uniqueCategories = products
            .map((p) => p.category)
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();
        uniqueCategories.sort();
        return ['Tất cả', ...uniqueCategories];
      },
      orElse: () => ['Tất cả'],
    );
  });

  // Modify filteredProductsProvider:
  final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
    final state = ref.watch(productListNotifierProvider);
    return state.products.whenData((products) {
      // 1. Filter by category first if not 'Tất cả'
      var list = products;
      if (state.selectedCategory != 'Tất cả') {
        list = list.where((p) => p.category == state.selectedCategory).toList();
      }

      // 2. Filter by search query
      if (state.searchQuery.trim().isEmpty) return list;

      final query = removeDiacritics(state.searchQuery.trim());
      return list.where((product) {
        final name = removeDiacritics(product.name);
        final description = removeDiacritics(product.description);
        return name.contains(query) || description.contains(query);
      }).toList();
    });
  });
  ```

- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test test/features/products/presentation/controllers/product_list_notifier_test.dart`
  Expected: All tests pass.

- [ ] **Step 5: Commit changes**
  Run:
  ```bash
  git add lib/features/products/presentation/controllers/product_list_state.dart lib/features/products/presentation/controllers/product_list_notifier.dart test/features/products/presentation/controllers/product_list_notifier_test.dart
  git commit -m "feat: add selectedCategory state, dynamic categoriesProvider, and update filteredProductsProvider with test verification"
  ```

---

### Task 2: Build Horizontal Categories Tab Bar UI

**Files:**
- Modify: `lib/features/home/presentation/views/home_screen.dart`
- Modify: `test/features/home/presentation/views/home_screen_test.dart`

**Interfaces:**
- Consumes: `categoriesProvider`, `productListNotifierProvider` state, and updates state via `selectCategory()`.
- Produces: Visual tab bar layout below Search bar.

- [ ] **Step 1: Write the failing widget test**
  Modify `test/features/home/presentation/views/home_screen_test.dart` to assert categories tab bar, ChoiceChips rendering, and category filtering behavior.

  ```dart
  // Inside home_screen_test.dart:
  // Re-define / update the existing test and add a category selection test:

  testWidgets(
      'HomeScreen renders search input, categories tabs, featured slider, and products list',
      (tester) async {
    final mockProducts = [
      const Product(
        id: 'p1',
        name: 'Điện thoại iPhone',
        description: 'Mô tả',
        price: 15000000.0,
        imageUrl: 'iphone.png',
        category: 'Điện thoại',
        isFeatured: true,
      ),
      const Product(
        id: 'p2',
        name: 'Laptop MacBook',
        description: 'Mô tả',
        price: 40000000.0,
        imageUrl: 'macbook.png',
        category: 'Laptop',
        isFeatured: false,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the repository so real providers can process values normally
          productRepositoryProvider.overrideWithValue(FakeProductRepository()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial load: Wait for stream
    await tester.pumpAndSettle();

    // Verify Search & Category Tab items exist
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Tất cả'), findsOneWidget);
    expect(find.text('Điện thoại'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);

    // Default tab is 'Tất cả' -> Featured slider and all products visible
    expect(find.byType(FeaturedProductSlider), findsOneWidget);
    expect(find.text('Điện thoại iPhone'), findsWidgets);
    expect(find.text('Laptop MacBook'), findsOneWidget);

    // Tap on 'Laptop' tab ChoiceChip
    await tester.tap(find.text('Laptop'));
    await tester.pumpAndSettle();

    // Now in Laptop tab: Featured slider is hidden, and only Laptop MacBook is shown
    expect(find.byType(FeaturedProductSlider), findsNothing);
    expect(find.text('Laptop MacBook'), findsOneWidget);
    expect(find.text('Điện thoại iPhone'), findsNothing);
  });
  ```

- [ ] **Step 2: Run test to verify it fails**
  Run: `flutter test test/features/home/presentation/views/home_screen_test.dart`
  Expected: Fail because categories chips and conditional slider hiding are not implemented on `HomeScreen`.

- [ ] **Step 3: Modify HomeScreen to implement Horizontal Tabs**
  Update `lib/features/home/presentation/views/home_screen.dart` with the new design:

  ```dart
  // Inside HomeScreen build method:
  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(filteredProductsProvider);
    final searchVal = _searchController.text;
    final categories = ref.watch(categoriesProvider);
    final listState = ref.watch(productListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đồ Điện Tử'),
        // ... actions code remains same ...
      ),
      body: Column(
        children: [
          // Search Field ... remains same ...
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField( ... ),
          ),

          // Horizontal Categories Scroll Tab Bar
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = listState.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref
                            .read(productListNotifierProvider.notifier)
                            .selectCategory(category);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: productsState.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Text('Không tìm thấy sản phẩm nào.'),
                  );
                }
                
                // Only get featured if tab is 'Tất cả'
                final showFeatured = listState.selectedCategory == 'Tất cả';
                final featured = showFeatured 
                    ? products.where((p) => p.isFeatured).toList()
                    : const <Product>[];

                return Column(
                  children: [
                    if (showFeatured && featured.isNotEmpty)
                      FeaturedProductSlider(products: featured),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: products[index]);
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
    );
  }
  ```

- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test test/features/home/presentation/views/home_screen_test.dart`
  Expected: PASS

- [ ] **Step 5: Commit changes**
  Run:
  ```bash
  git add lib/features/home/presentation/views/home_screen.dart test/features/home/presentation/views/home_screen_test.dart
  git commit -m "feat: implement horizontal category tab bar using ChoiceChips and conditional slider rendering"
  ```
