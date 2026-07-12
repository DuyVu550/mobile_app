# Product Filtering Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement product filtering by price range, minimum rating, and promotion status.

**Architecture:** Extend the existing Riverpod-based client-side filtering. Modify the product domain and data layers, add filters to `ProductListState` and `ProductListNotifier`, extend `filteredProductsProvider` to filter matching products, and implement a custom Bottom Sheet UI.

**Tech Stack:** Flutter, Riverpod, Freezed, Cloud Firestore.

## Global Constraints
- Do not add any new third-party packages.
- Ensure all tests run successfully using: `flutter test`
- Always run `dart run build_runner build --delete-conflicting-outputs` after updating Freezed files.

---

### Task 1: Update Product Data and Entity Layers

**Files:**
- Modify: [product.dart](file:///d:/mobile_app/lib/features/products/domain/entities/product.dart)
- Modify: [product_model.dart](file:///d:/mobile_app/lib/features/products/data/models/product_model.dart)
- Modify: [product_list_notifier_test.dart](file:///d:/mobile_app/test/features/products/presentation/controllers/product_list_notifier_test.dart)

**Interfaces:**
- Consumes: Firestore maps and JSON.
- Produces: `Product` with `double rating` and `bool hasPromotion` fields.

- [ ] **Step 1: Modify the Product entity**
  Add fields to `lib/features/products/domain/entities/product.dart`:
  ```dart
  class Product {
    final String id;
    final String name;
    final String description;
    final double price;
    final String imageUrl;
    final String category;
    final bool isFeatured;
    final double rating;        // New
    final bool hasPromotion;    // New

    const Product({
      required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.imageUrl,
      required this.category,
      required this.isFeatured,
      required this.rating,
      required this.hasPromotion,
    });
  }
  ```

- [ ] **Step 2: Modify the ProductModel data model**
  Update `lib/features/products/data/models/product_model.dart` to add the properties and update `fromFirestore` and `toEntity`:
  ```dart
  @freezed
  class ProductModel with _$ProductModel implements Product {
    const factory ProductModel({
      required String id,
      required String name,
      required String description,
      required double price,
      required String imageUrl,
      required String category,
      required bool isFeatured,
      required double rating,        // New
      required bool hasPromotion,    // New
    }) = _ProductModel;

    const ProductModel._();

    factory ProductModel.fromJson(Map<String, dynamic> json) =>
        _$ProductModelFromJson(json);

    factory ProductModel.fromFirestore(String id, Map<String, dynamic> data) {
      return ProductModel(
        id: id,
        name: (data['name'] ?? '') as String,
        description: (data['description'] ?? '') as String,
        price: ((data['price'] ?? 0) as num).toDouble(),
        imageUrl: (data['imageUrl'] ?? '') as String,
        category: (data['category'] ?? '') as String,
        isFeatured: (data['isFeatured'] ?? false) as bool,
        rating: ((data['rating'] ?? 0.0) as num).toDouble(),        // New
        hasPromotion: (data['hasPromotion'] ?? false) as bool,      // New
      );
    }

    Product toEntity() {
      return Product(
        id: id,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        category: category,
        isFeatured: isFeatured,
        rating: rating,
        hasPromotion: hasPromotion,
      );
    }
  }
  ```

- [ ] **Step 3: Update Mock data in unit tests**
  Update `FakeProductRepository` in `test/features/products/presentation/controllers/product_list_notifier_test.dart` to match the new constructor:
  ```dart
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
          rating: 4.8,
          hasPromotion: true,
        ),
        Product(
          id: 'p2',
          name: 'Laptop MacBook',
          description: 'MacBook Pro M3',
          price: 45000000.0,
          imageUrl: 'macbook.png',
          category: 'Laptop',
          isFeatured: false,
          rating: 4.5,
          hasPromotion: false,
        ),
      ]));
    }
  }
  ```

- [ ] **Step 4: Regenerate Freezed and JSON serialization files**
  Run command: `dart run build_runner build --delete-conflicting-outputs`
  Expected: Successful compilation of code generators.

- [ ] **Step 5: Run tests to verify setup passes**
  Run: `flutter test test/features/products/presentation/controllers/product_list_notifier_test.dart`
  Expected: PASS

- [ ] **Step 6: Commit changes**
  ```bash
  git add lib/features/products/domain/entities/product.dart lib/features/products/data/models/product_model.dart test/features/products/presentation/controllers/product_list_notifier_test.dart
  git commit -m "feat: add rating and hasPromotion fields to product data model"
  ```

---

### Task 2: Extend Product Filter State and Notifier

**Files:**
- Modify: [product_list_state.dart](file:///d:/mobile_app/lib/features/products/presentation/controllers/product_list_state.dart)
- Modify: [product_list_notifier.dart](file:///d:/mobile_app/lib/features/products/presentation/controllers/product_list_notifier.dart)

**Interfaces:**
- Consumes: Filter UI actions.
- Produces: `ProductListState` with updated `minPrice`, `maxPrice`, `minRating`, `onlyPromotions` fields.

- [ ] **Step 1: Update ProductListState Freezed model**
  Modify `lib/features/products/presentation/controllers/product_list_state.dart` to add the properties:
  ```dart
  @freezed
  class ProductListState with _$ProductListState {
    const factory ProductListState({
      @Default('') String searchQuery,
      @Default('Tất cả') String selectedCategory,
      @Default(AsyncValue.loading()) AsyncValue<List<Product>> products,
      double? minPrice,
      double? maxPrice,
      double? minRating,
      @Default(false) bool onlyPromotions,
    }) = _ProductListState;
  }
  ```

- [ ] **Step 2: Regenerate State Freezed files**
  Run: `dart run build_runner build --delete-conflicting-outputs`
  Expected: Successful generation of state code.

- [ ] **Step 3: Update ProductListNotifier with apply and clear methods**
  Modify `lib/features/products/presentation/controllers/product_list_notifier.dart` to add `applyFilters` and `clearFilters`:
  ```dart
  class ProductListNotifier extends StateNotifier<ProductListState> {
    final WatchProductsUseCase _watchProductsUseCase;

    ProductListNotifier(this._watchProductsUseCase)
        : super(const ProductListState()) {
      _init();
    }

    void _init() {
      _watchProductsUseCase.execute().listen((result) {
        result.fold(
          (error) => state = state.copyWith(
              products: AsyncValue.error(error, StackTrace.current)),
          (list) => state = state.copyWith(products: AsyncValue.data(list)),
        );
      });
    }

    void updateSearchQuery(String query) {
      state = state.copyWith(searchQuery: query);
    }

    void selectCategory(String category) {
      state = state.copyWith(selectedCategory: category);
    }

    void applyFilters({
      double? minPrice,
      double? maxPrice,
      double? minRating,
      required bool onlyPromotions,
    }) {
      state = state.copyWith(
        minPrice: minPrice,
        maxPrice: maxPrice,
        minRating: minRating,
        onlyPromotions: onlyPromotions,
      );
    }

    void clearFilters() {
      state = state.copyWith(
        minPrice: null,
        maxPrice: null,
        minRating: null,
        onlyPromotions: false,
      );
    }
  }
  ```

- [ ] **Step 4: Commit changes**
  ```bash
  git add lib/features/products/presentation/controllers/product_list_state.dart lib/features/products/presentation/controllers/product_list_notifier.dart
  git commit -m "feat: add filtering properties and methods to ProductListState and Notifier"
  ```

---

### Task 3: Update Filter Logic and Write Unit Tests

**Files:**
- Modify: [product_list_notifier.dart](file:///d:/mobile_app/lib/features/products/presentation/controllers/product_list_notifier.dart)
- Modify: [product_list_notifier_test.dart](file:///d:/mobile_app/test/features/products/presentation/controllers/product_list_notifier_test.dart)

**Interfaces:**
- Consumes: `productListNotifierProvider` state.
- Produces: Filtered list of products via `filteredProductsProvider`.

- [ ] **Step 1: Implement filtering logic in filteredProductsProvider**
  Modify `lib/features/products/presentation/controllers/product_list_notifier.dart` to filter by price, rating, and promotions:
  ```dart
  final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
    final state = ref.watch(productListNotifierProvider);
    return state.products.whenData((products) {
      // 1. Lọc theo danh mục nếu không phải 'Tất cả'
      var list = products;
      if (state.selectedCategory != 'Tất cả') {
        list =
            list.where((p) => p.category == state.selectedCategory).toList();
      }

      // 2. Lọc theo từ khóa tìm kiếm
      if (state.searchQuery.trim().isNotEmpty) {
        final query = removeDiacritics(state.searchQuery.trim());
        list = list.where((product) {
          final name = removeDiacritics(product.name);
          final description = removeDiacritics(product.description);
          return name.contains(query) || description.contains(query);
        }).toList();
      }

      // 3. Lọc theo khoảng giá
      if (state.minPrice != null) {
        list = list.where((p) => p.price >= state.minPrice!).toList();
      }
      if (state.maxPrice != null) {
        list = list.where((p) => p.price <= state.maxPrice!).toList();
      }

      // 4. Lọc theo xếp hạng tối thiểu
      if (state.minRating != null) {
        list = list.where((p) => p.rating >= state.minRating!).toList();
      }

      // 5. Lọc theo chương trình khuyến mại
      if (state.onlyPromotions) {
        list = list.where((p) => p.hasPromotion).toList();
      }

      return list;
    });
  });
  ```

- [ ] **Step 2: Add failing tests for price, rating, and promotion filtering**
  Add unit tests inside `test/features/products/presentation/controllers/product_list_notifier_test.dart`:
  ```dart
  test('ProductListNotifier filters products by price range, rating, and promotions',
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

    // Initial check
    var filtered = container.read(filteredProductsProvider).value;
    expect(filtered?.length, 2);

    // 1. Filter by price range
    container
        .read(productListNotifierProvider.notifier)
        .applyFilters(minPrice: 30000000.0, onlyPromotions: false);
    filtered = container.read(filteredProductsProvider).value;
    expect(filtered?.length, 1);
    expect(filtered?.first.name, 'Laptop MacBook');

    // 2. Filter by promotion
    container
        .read(productListNotifierProvider.notifier)
        .applyFilters(onlyPromotions: true);
    filtered = container.read(filteredProductsProvider).value;
    expect(filtered?.length, 1);
    expect(filtered?.first.name, 'Điện thoại iPhone');

    // 3. Filter by rating
    container
        .read(productListNotifierProvider.notifier)
        .applyFilters(minRating: 4.6, onlyPromotions: false);
    filtered = container.read(filteredProductsProvider).value;
    expect(filtered?.length, 1);
    expect(filtered?.first.name, 'Điện thoại iPhone');

    // 4. Reset filters
    container.read(productListNotifierProvider.notifier).clearFilters();
    filtered = container.read(filteredProductsProvider).value;
    expect(filtered?.length, 2);
  });
  ```

- [ ] **Step 3: Run the unit tests**
  Run: `flutter test test/features/products/presentation/controllers/product_list_notifier_test.dart`
  Expected: PASS

- [ ] **Step 4: Commit changes**
  ```bash
  git add lib/features/products/presentation/controllers/product_list_notifier.dart test/features/products/presentation/controllers/product_list_notifier_test.dart
  git commit -m "feat: implement filter calculations in filteredProductsProvider and verify with unit tests"
  ```

---

### Task 4: Implement Filter Bottom Sheet and HomeScreen Integration

**Files:**
- Create: [product_filter_bottom_sheet.dart](file:///d:/mobile_app/lib/features/products/presentation/views/widgets/product_filter_bottom_sheet.dart)
- Modify: [home_screen.dart](file:///d:/mobile_app/lib/features/home/presentation/views/home_screen.dart)

**Interfaces:**
- Consumes: `productListNotifierProvider` to retrieve active state and apply modifications.
- Produces: Bottom sheet UI triggered by a filter icon.

- [ ] **Step 1: Create the Filter Bottom Sheet widget**
  Create `lib/features/products/presentation/views/widgets/product_filter_bottom_sheet.dart` with stateful text controllers and presets:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../controllers/product_list_notifier.dart';

  class ProductFilterBottomSheet extends ConsumerStatefulWidget {
    const ProductFilterBottomSheet({super.key});

    @override
    ConsumerState<ProductFilterBottomSheet> createState() =>
        _ProductFilterBottomSheetState();
  }

  class _ProductFilterBottomSheetState
      extends ConsumerState<ProductFilterBottomSheet> {
    late final TextEditingController _minPriceController;
    late final TextEditingController _maxPriceController;
    double? _selectedMinRating;
    bool _onlyPromotions = false;

    @override
    void initState() {
      super.initState();
      final state = ref.read(productListNotifierProvider);
      _minPriceController = TextEditingController(
          text: state.minPrice != null ? state.minPrice!.toInt().toString() : '');
      _maxPriceController = TextEditingController(
          text: state.maxPrice != null ? state.maxPrice!.toInt().toString() : '');
      _selectedMinRating = state.minRating;
      _onlyPromotions = state.onlyPromotions;
    }

    @override
    void dispose() {
      _minPriceController.dispose();
      _maxPriceController.dispose();
      super.dispose();
    }

    void _selectPricePreset(double? min, double? max) {
      setState(() {
        _minPriceController.text = min != null ? min.toInt().toString() : '';
        _maxPriceController.text = max != null ? max.toInt().toString() : '';
      });
    }

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bộ lọc tìm kiếm',
                    style: TextStyle(fontSize: 18, fontWeight: bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Khoảng giá
              const Text(
                'Khoảng giá (VND)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Từ',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('—'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Đến',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Preset giá
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      label: const Text('Dưới 5tr'),
                      onPressed: () => _selectPricePreset(0, 5000000),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      label: const Text('5tr - 15tr'),
                      onPressed: () => _selectPricePreset(5000000, 15000000),
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      label: const Text('Trên 15tr'),
                      onPressed: () => _selectPricePreset(15000000, null),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Đánh giá sao tối thiểu
              const Text(
                'Đánh giá',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _selectedMinRating == null,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedMinRating = null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('4★ trở lên'),
                    selected: _selectedMinRating == 4.0,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedMinRating = 4.0);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('3★ trở lên'),
                    selected: _selectedMinRating == 3.0,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedMinRating = 3.0);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Khuyến mãi
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Chỉ hiện sản phẩm khuyến mãi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                value: _onlyPromotions,
                onChanged: (val) {
                  setState(() => _onlyPromotions = val);
                },
              ),
              const SizedBox(height: 24),

              // Áp dụng / Hủy
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(productListNotifierProvider.notifier)
                            .clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Thiết lập lại'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final minVal = double.tryParse(_minPriceController.text);
                        final maxVal = double.tryParse(_maxPriceController.text);
                        ref
                            .read(productListNotifierProvider.notifier)
                            .applyFilters(
                              minPrice: minVal,
                              maxPrice: maxVal,
                              minRating: _selectedMinRating,
                              onlyPromotions: _onlyPromotions,
                            );
                        Navigator.pop(context);
                      },
                      child: const Text('Áp dụng'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }
  }
  ```

- [ ] **Step 2: Add Filter Icon and link sheet in HomeScreen**
  Modify `lib/features/home/presentation/views/home_screen.dart` to place the Filter button next to the Search field:
  ```dart
  // Import:
  import '../../../products/presentation/views/widgets/product_filter_bottom_sheet.dart';

  // Inside build method of _HomeScreenState:
  final hasActiveFilters = listState.minPrice != null ||
      listState.maxPrice != null ||
      listState.minRating != null ||
      listState.onlyPromotions;

  // Replace search text field with a Row:
  Padding(
    padding: const EdgeInsets.all(12.0),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              ref
                  .read(productListNotifierProvider.notifier)
                  .updateSearchQuery(val);
            },
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sản phẩm...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchVal.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(productListNotifierProvider.notifier)
                            .updateSearchQuery('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: hasActiveFilters ? Theme.of(context).primaryColor : null,
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const ProductFilterBottomSheet(),
            );
          },
        ),
      ],
    ),
  ),
  ```

- [ ] **Step 3: Run all tests to make sure no regressions occur**
  Run: `flutter test`
  Expected: PASS

- [ ] **Step 4: Commit changes**
  ```bash
  git add lib/features/products/presentation/views/widgets/product_filter_bottom_sheet.dart lib/features/home/presentation/views/home_screen.dart
  git commit -m "feat: integrate filter bottom sheet into HomeScreen UI"
  ```
