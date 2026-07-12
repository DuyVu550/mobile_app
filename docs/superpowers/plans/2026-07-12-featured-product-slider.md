# Featured Product Image Slideshow (Slide Image) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a featured product image slideshow on the HomeScreen that displays products marked as `isFeatured` from Firestore, cycles automatically every 3 seconds, and navigates to a product detail screen on tap.

**Architecture:** Update the product domain entity and data models to include `isFeatured`. Create a reusable `FeaturedProductSlider` widget using `PageView` and a timer. Create a `ProductDetailScreen` widget. Integrate them into the `HomeScreen`.

**Tech Stack:** Flutter, Riverpod, Cloud Firestore, Freezed, build_runner.

## Global Constraints
* Naming conventions: snake_case for files, PascalCase for classes, camelCase with `Provider` suffix for providers.
* Layer isolation: Domain layer must NOT import Flutter, Riverpod, or Data packages.
* Immutability: Use Freezed for models.
* Code analysis: `flutter analyze` must run cleanly.
* Tests: `flutter test` must pass all tests.

---

### Task 1: Update Product Entity and Model (isFeatured field)

**Files:**
* Modify: `lib/features/products/domain/entities/product.dart`
* Modify: `lib/features/products/data/models/product_model.dart`
* Test: `test/features/products/domain/usecases/watch_products_usecase_test.dart`
* Test: `test/features/products/data/repositories/product_repository_impl_test.dart`
* Test: `test/features/products/presentation/controllers/product_list_notifier_test.dart`
* Test: `test/features/products/presentation/views/widgets/product_card_test.dart`
* Test: `test/features/home/presentation/views/home_screen_test.dart`

**Interfaces:**
* Consumes: Existing product entities and serialization logic.
* Produces: `Product` and `ProductModel` updated with a boolean `isFeatured` field.

- [ ] **Step 1: Update Product Entity**
  Modify `lib/features/products/domain/entities/product.dart`:
  ```dart
  class Product {
    final String id;
    final String name;
    final String description;
    final double price;
    final String imageUrl;
    final String category;
    final bool isFeatured;

    const Product({
      required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.imageUrl,
      required this.category,
      required this.isFeatured,
    });
  }
  ```

- [ ] **Step 2: Update Product Model**
  Modify `lib/features/products/data/models/product_model.dart`:
  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';
  import '../../domain/entities/product.dart';

  part 'product_model.freezed.dart';
  part 'product_model.g.dart';

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
      );
    }
  }
  ```

- [ ] **Step 3: Run build_runner**
  Run: `dart run build_runner build --delete-conflicting-outputs`
  Expected: Successful code generation for `product_model.freezed.dart` and `product_model.g.dart`.

- [ ] **Step 4: Update WatchProductsUseCase Test**
  Modify `test/features/products/domain/usecases/watch_products_usecase_test.dart` to specify `isFeatured: false`:
  ```dart
      yield const Right([
        Product(
          id: 'p1',
          name: 'Điện thoại iPhone 15',
          description: 'iPhone 15 Pro Max',
          price: 25000000.0,
          imageUrl: 'iphone15.png',
          category: 'Điện thoại',
          isFeatured: false,
        ),
      ]);
  ```

- [ ] **Step 5: Update ProductRepositoryImpl Test**
  Modify `test/features/products/data/repositories/product_repository_impl_test.dart` to specify `isFeatured: false`:
  ```dart
        const ProductModel(
          id: 'p1',
          name: 'Điện thoại iPhone 15',
          description: 'iPhone 15 Pro Max',
          price: 25000000.0,
          imageUrl: 'iphone15.png',
          category: 'Điện thoại',
          isFeatured: false,
        ),
  ```

- [ ] **Step 6: Update ProductListNotifier Test**
  Modify `test/features/products/presentation/controllers/product_list_notifier_test.dart` to specify `isFeatured: false`:
  ```dart
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
  ```

- [ ] **Step 7: Update ProductCard Test**
  Modify `test/features/products/presentation/views/widgets/product_card_test.dart` to specify `isFeatured: false`:
  ```dart
      const product = Product(
        id: 'p1',
        name: 'Điện thoại iPhone 15',
        description: 'iPhone 15 Pro Max',
        price: 25000000.0,
        imageUrl: 'iphone15.png',
        category: 'Điện thoại',
        isFeatured: false,
      );
  ```

- [ ] **Step 8: Update HomeScreen Test**
  Modify `test/features/home/presentation/views/home_screen_test.dart` to specify `isFeatured: false`:
  ```dart
      final mockProducts = [
        const Product(
          id: 'p1',
          name: 'Điện thoại iPhone',
          description: 'Mô tả',
          price: 15000000.0,
          imageUrl: 'iphone.png',
          category: 'Điện thoại',
          isFeatured: false,
        ),
      ];
  ```

- [ ] **Step 9: Run tests**
  Run: `flutter test`
  Expected: All existing tests compile and pass.

- [ ] **Step 10: Commit**
  Run: `git add .`
  Run: `git commit -m "feat: add isFeatured field to product model"`

---

### Task 2: Create Product Detail Screen

**Files:**
* Create: `lib/features/products/presentation/views/product_detail_screen.dart`
* Create: `test/features/products/presentation/views/product_detail_screen_test.dart`

**Interfaces:**
* Consumes: `Product` entity.
* Produces: `ProductDetailScreen` widget.

- [ ] **Step 1: Create ProductDetailScreen**
  Create `lib/features/products/presentation/views/product_detail_screen.dart`:
  ```dart
  import 'package:flutter/material.dart';
  import '../../domain/entities/product.dart';

  class ProductDetailScreen extends StatelessWidget {
    final Product product;
    const ProductDetailScreen({super.key, required this.product});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(product.name),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                product.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.category,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${product.price.toStringAsFixed(0)}đ',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    Text(
                      'Mô tả sản phẩm',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
  ```

- [ ] **Step 2: Create ProductDetailScreen Unit/Widget Test**
  Create `test/features/products/presentation/views/product_detail_screen_test.dart`:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:toy_app/features/products/domain/entities/product.dart';
  import 'package:toy_app/features/products/presentation/views/product_detail_screen.dart';

  void main() {
    testWidgets('ProductDetailScreen renders product details', (tester) async {
      const product = Product(
        id: 'p1',
        name: 'iPhone 15 Pro',
        description: 'Điện thoại cao cấp của Apple',
        price: 25000000.0,
        imageUrl: 'iphone15.png',
        category: 'Điện thoại',
        isFeatured: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ProductDetailScreen(product: product),
        ),
      );

      expect(find.text('iPhone 15 Pro'), findsOneWidget);
      expect(find.text('Điện thoại'), findsOneWidget);
      expect(find.text('25000000đ'), findsOneWidget);
      expect(find.text('Điện thoại cao cấp của Apple'), findsOneWidget);
    });
  }
  ```

- [ ] **Step 3: Run new widget test**
  Run: `flutter test test/features/products/presentation/views/product_detail_screen_test.dart`
  Expected: PASS

- [ ] **Step 4: Commit**
  Run: `git add .`
  Run: `git commit -m "feat: implement product detail screen and tests"`

---

### Task 3: Create Featured Product Slider Widget

**Files:**
* Create: `lib/features/products/presentation/views/widgets/featured_product_slider.dart`
* Create: `test/features/products/presentation/views/widgets/featured_product_slider_test.dart`

**Interfaces:**
* Consumes: `Product` entity, `ProductDetailScreen` widget.
* Produces: `FeaturedProductSlider` widget.

- [ ] **Step 1: Create FeaturedProductSlider Widget**
  Create `lib/features/products/presentation/views/widgets/featured_product_slider.dart`:
  ```dart
  import 'dart:async';
  import 'package:flutter/material.dart';
  import '../../domain/entities/product.dart';
  import '../product_detail_screen.dart';

  class FeaturedProductSlider extends StatefulWidget {
    final List<Product> products;
    const FeaturedProductSlider({super.key, required this.products});

    @override
    State<FeaturedProductSlider> createState() => _FeaturedProductSliderState();
  }

  class _FeaturedProductSliderState extends State<FeaturedProductSlider> {
    late final PageController _pageController;
    Timer? _timer;
    int _currentPage = 0;

    @override
    void initState() {
      super.initState();
      _pageController = PageController(initialPage: 0);
      _startTimer();
    }

    void _startTimer() {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted || widget.products.isEmpty) return;
        
        final nextPage = (_currentPage + 1) % widget.products.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      });
    }

    @override
    void dispose() {
      _timer?.cancel();
      _pageController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      if (widget.products.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final product = widget.products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black87],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${product.price.toStringAsFixed(0)}đ',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.products.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                height: 8,
                width: _currentPage == index ? 16 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.blue : Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
  ```

- [ ] **Step 2: Create FeaturedProductSlider Widget Test**
  Create `test/features/products/presentation/views/widgets/featured_product_slider_test.dart`:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:toy_app/features/products/domain/entities/product.dart';
  import 'package:toy_app/features/products/presentation/views/widgets/featured_product_slider.dart';
  import 'package:toy_app/features/products/presentation/views/product_detail_screen.dart';

  void main() {
    testWidgets('FeaturedProductSlider renders products and detail page navigation', (tester) async {
      final products = [
        const Product(
          id: 'p1',
          name: 'iPhone 15',
          description: 'Desc',
          price: 20000000.0,
          imageUrl: 'iphone15.png',
          category: 'Điện thoại',
          isFeatured: true,
        ),
        const Product(
          id: 'p2',
          name: 'MacBook Pro',
          description: 'Desc',
          price: 40000000.0,
          imageUrl: 'macbook.png',
          category: 'Laptop',
          isFeatured: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeaturedProductSlider(products: products),
          ),
        ),
      );

      // Verify slides rendering
      expect(find.text('iPhone 15'), findsOneWidget);
      expect(find.text('20000000đ'), findsOneWidget);

      // Tap on the slider to check navigation
      await tester.tap(find.text('iPhone 15'));
      await tester.pumpAndSettle();

      // Check if navigated to ProductDetailScreen
      expect(find.byType(ProductDetailScreen), findsOneWidget);
    });
  }
  ```

- [ ] **Step 3: Run slider widget test**
  Run: `flutter test test/features/products/presentation/views/widgets/featured_product_slider_test.dart`
  Expected: PASS

- [ ] **Step 4: Commit**
  Run: `git add .`
  Run: `git commit -m "feat: implement featured product slider widget and tests"`

---

### Task 4: Integrate Slider in HomeScreen

**Files:**
* Modify: `lib/features/home/presentation/views/home_screen.dart`
* Modify: `test/features/home/presentation/views/home_screen_test.dart`

**Interfaces:**
* Consumes: `FeaturedProductSlider` widget, `filteredProductsProvider`.
* Produces: Integrated `HomeScreen` showing the image slideshow for featured items.

- [ ] **Step 1: Modify HomeScreen**
  Modify `lib/features/home/presentation/views/home_screen.dart` to insert `FeaturedProductSlider` below the search input field:
  ```dart
  // Import:
  import '../../../products/presentation/views/widgets/featured_product_slider.dart';
  ```
  And inside the `HomeScreen` State `build` method under the `data: (products)` block:
  ```dart
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy sản phẩm nào.'),
                    );
                  }
                  final featured = products.where((p) => p.isFeatured).toList();
                  return Column(
                    children: [
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
  ```
  Wait! Let's view the exact layout of `HomeScreen` in `lib/features/home/presentation/views/home_screen.dart` to verify if this column matches properly. Currently, the body has a `Column` with `children: [TextField, Expanded(child: productsState.when(...))]`. So inside the `productsState.when` data block, we already have `Expanded` taking up the space. If we wrap it inside another `Column`, we should do `FeaturedProductSlider` first, then `Expanded` containing the `GridView.builder`. This matches the code above perfectly!

- [ ] **Step 2: Update HomeScreen Test**
  Modify `test/features/home/presentation/views/home_screen_test.dart` to mock both featured and non-featured products, and assert that the slider is rendered:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:toy_app/features/home/presentation/views/home_screen.dart';
  import 'package:toy_app/features/products/presentation/controllers/product_list_notifier.dart';
  import 'package:toy_app/features/products/domain/entities/product.dart';
  import 'package:toy_app/features/products/presentation/views/widgets/featured_product_slider.dart';

  void main() {
    testWidgets('HomeScreen renders search input, featured slider, and products list',
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
            filteredProductsProvider
                .overrideWithValue(AsyncValue.data(mockProducts)),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Tìm kiếm sản phẩm...'), findsOneWidget);
      expect(find.byType(FeaturedProductSlider), findsOneWidget);
      expect(find.text('Điện thoại iPhone'), findsWidgets); // Appears in both slider and card
      expect(find.text('Laptop MacBook'), findsOneWidget); // Appears only in card
    });
  }
  ```

- [ ] **Step 3: Run all tests**
  Run: `flutter test`
  Expected: All tests pass.

- [ ] **Step 4: Commit and finalize**
  Run: `git add .`
  Run: `git commit -m "feat: integrate featured product slider into HomeScreen"`
