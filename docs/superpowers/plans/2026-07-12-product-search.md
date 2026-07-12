# Product Search by Name Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a real-time product search feature by name (keyword) on the main HomeScreen, fetching product data from Firestore `/products` collection and performing client-side filtering.

**Architecture:** Create a new feature module `products` following the Clean Architecture pattern with distinct data, domain, and presentation layers. Update the existing `home` module to show the search bar and product list.

**Tech Stack:** Flutter, Flutter Riverpod, Cloud Firestore, Freezed, fpdart, json_serializable.

## Global Constraints
* Naming conventions: snake_case for files, PascalCase for classes, camelCase with `Provider` suffix for providers.
* Layer isolation: Domain layer must NOT import Flutter, Riverpod, or Data packages.
* Immutability: Use Freezed for models.
* Code analysis: `flutter analyze` must run cleanly.
* Tests: `flutter test` must pass all tests.

---

### Task 1: Domain Layer (Product Entity, Repository Interface, WatchProductsUseCase)

**Files:**
* Create: `lib/features/products/domain/entities/product.dart`
* Create: `lib/features/products/domain/repositories/product_repository.dart`
* Create: `lib/features/products/domain/usecases/watch_products_usecase.dart`
* Create: `test/features/products/domain/usecases/watch_products_usecase_test.dart`

**Interfaces:**
* Produces: `Product` entity, `ProductRepository` interface, and `WatchProductsUseCase` usecase.

- [ ] **Step 1: Write the failing unit test for WatchProductsUseCase**
  Create `test/features/products/domain/usecases/watch_products_usecase_test.dart`:
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:fpdart/fpdart.dart';
  import 'package:toy_app/features/products/domain/entities/product.dart';
  import 'package:toy_app/features/products/domain/repositories/product_repository.dart';
  import 'package:toy_app/features/products/domain/usecases/watch_products_usecase.dart';

  class FakeProductRepository implements ProductRepository {
    @override
    Stream<Either<String, List<Product>>> watchProducts() async* {
      yield const Right([
        Product(
          id: 'p1',
          name: 'Điện thoại iPhone 15',
          description: 'iPhone 15 Pro Max',
          price: 25000000.0,
          imageUrl: 'iphone15.png',
          category: 'Điện thoại',
        ),
      ]);
    }
  }

  void main() {
    test('WatchProductsUseCase should execute and return list of products', () async {
      final repository = FakeProductRepository();
      final useCase = WatchProductsUseCase(repository);

      final result = await useCase.execute().first;
      expect(result.isRight(), isTrue);
      result.match(
        (l) => fail('Should be right'),
        (r) {
          expect(r.length, 1);
          expect(r.first.name, 'Điện thoại iPhone 15');
        },
      );
    });
  }
  ```

- [ ] **Step 2: Run test to verify compile failure**
  Run: `flutter test test/features/products/domain/usecases/watch_products_usecase_test.dart`
  Expected: Compilation fail due to missing Product, ProductRepository, and WatchProductsUseCase classes.

- [ ] **Step 3: Implement the Domain classes**
  Create `lib/features/products/domain/entities/product.dart`:
  ```dart
  class Product {
    final String id;
    final String name;
    final String description;
    final double price;
    final String imageUrl;
    final String category;

    const Product({
      required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.imageUrl,
      required this.category,
    });
  }
  ```

  Create `lib/features/products/domain/repositories/product_repository.dart`:
  ```dart
  import 'package:fpdart/fpdart.dart';
  import '../entities/product.dart';

  abstract interface class ProductRepository {
    Stream<Either<String, List<Product>>> watchProducts();
  }
  ```

  Create `lib/features/products/domain/usecases/watch_products_usecase.dart`:
  ```dart
  import 'package:fpdart/fpdart.dart';
  import '../entities/product.dart';
  import '../repositories/product_repository.dart';

  class WatchProductsUseCase {
    final ProductRepository _repository;

    WatchProductsUseCase(this._repository);

    Stream<Either<String, List<Product>>> execute() {
      return _repository.watchProducts();
    }
  }
  ```

- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test test/features/products/domain/usecases/watch_products_usecase_test.dart`
  Expected: PASS

- [ ] **Step 5: Commit Domain changes**
  Run: `git add lib/features/products/domain/ test/features/products/domain/`
  Run: `git commit -m "feat(products): Add Product entity, WatchProductsUseCase, and ProductRepository interface"`

---

### Task 2: Data Layer (ProductModel, RemoteDataSource, RepositoryImpl)

**Files:**
* Create: `lib/features/products/data/models/product_model.dart`
* Create: `lib/features/products/data/datasources/product_remote_datasource.dart`
* Create: `lib/features/products/data/repositories/product_repository_impl.dart`
* Create: `test/features/products/data/repositories/product_repository_impl_test.dart`

**Interfaces:**
* Consumes: `Product` entity, `ProductRepository` interface.
* Produces: `ProductModel` serialized class and concrete repository implementation of `watchProducts()`.

- [ ] **Step 1: Write unit test for ProductRepositoryImpl.watchProducts()**
  Create `test/features/products/data/repositories/product_repository_impl_test.dart`:
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:toy_app/features/products/data/repositories/product_repository_impl.dart';
  import 'package:toy_app/features/products/data/datasources/product_remote_datasource.dart';
  import 'package:toy_app/features/products/data/models/product_model.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

  class FakeProductRemoteDataSource implements ProductRemoteDataSource {
    @override
    Stream<List<ProductModel>> watchProducts() {
      return Stream.value([
        const ProductModel(
          id: 'p1',
          name: 'Điện thoại iPhone 15',
          description: 'iPhone 15 Pro Max',
          price: 25000000.0,
          imageUrl: 'iphone15.png',
          category: 'Điện thoại',
        ),
      ]);
    }

    @override
    FirebaseFirestore get _firestore => throw UnimplementedError();
  }

  void main() {
    test('ProductRepositoryImpl.watchProducts maps ProductModel to Product entity', () async {
      final dataSource = FakeProductRemoteDataSource();
      final repository = ProductRepositoryImpl(dataSource);

      final result = await repository.watchProducts().first;
      expect(result.isRight(), isTrue);
      result.match(
        (l) => fail('Should be right'),
        (r) {
          expect(r.length, 1);
          expect(r.first.id, 'p1');
          expect(r.first.name, 'Điện thoại iPhone 15');
        },
      );
    });
  }
  ```

- [ ] **Step 2: Implement ProductModel and Remote Data Source**
  Create `lib/features/products/data/models/product_model.dart`:
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
      );
    }
  }
  ```

  Create `lib/features/products/data/datasources/product_remote_datasource.dart`:
  ```dart
  import 'package:cloud_firestore/cloud_firestore.dart';
  import '../models/product_model.dart';

  class ProductRemoteDataSource {
    final FirebaseFirestore _firestore;

    ProductRemoteDataSource(this._firestore);

    static const _collection = 'products';

    Stream<List<ProductModel>> watchProducts() {
      return _firestore
          .collection(_collection)
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc.id, doc.data()))
              .toList());
    }
  }
  ```

- [ ] **Step 3: Run build_runner to generate Freezed and JSON serializable files**
  Run: `flutter pub run build_runner build --delete-conflicting-outputs`
  Expected: Clean build success with `product_model.freezed.dart` and `product_model.g.dart` generated.

- [ ] **Step 4: Implement RepositoryImpl**
  Create `lib/features/products/data/repositories/product_repository_impl.dart`:
  ```dart
  import 'package:fpdart/fpdart.dart';
  import '../../domain/entities/product.dart';
  import '../../domain/repositories/product_repository.dart';
  import '../datasources/product_remote_datasource.dart';

  class ProductRepositoryImpl implements ProductRepository {
    final ProductRemoteDataSource _remoteDataSource;

    const ProductRepositoryImpl(this._remoteDataSource);

    @override
    Stream<Either<String, List<Product>>> watchProducts() async* {
      try {
        await for (final models in _remoteDataSource.watchProducts()) {
          yield Right(models.map((m) => m.toEntity()).toList());
        }
      } catch (e) {
        yield Left('Không tải được danh sách sản phẩm: $e');
      }
    }
  }
  ```

- [ ] **Step 5: Run tests to verify they pass**
  Run: `flutter test test/features/products/data/repositories/product_repository_impl_test.dart`
  Expected: PASS

- [ ] **Step 6: Commit Data changes**
  Run: `git add lib/features/products/data/ test/features/products/data/`
  Run: `git commit -m "feat(products): Implement ProductModel, ProductRemoteDataSource, and ProductRepositoryImpl"`

---

### Task 3: Presentation Layer (State and StateNotifier Providers)

**Files:**
* Create: `lib/features/products/presentation/controllers/product_list_state.dart`
* Create: `lib/features/products/presentation/controllers/product_list_notifier.dart`
* Create: `test/features/products/presentation/controllers/product_list_notifier_test.dart`

**Interfaces:**
* Consumes: `WatchProductsUseCase` usecase.
* Produces: `productListNotifierProvider` state notifier provider and `filteredProductsProvider` product list stream provider.

- [ ] **Step 1: Write unit test for ProductListNotifier**
  Create `test/features/products/presentation/controllers/product_list_notifier_test.dart`:
  ```dart
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
        ),
        Product(
          id: 'p2',
          name: 'Laptop MacBook',
          description: 'MacBook Pro M3',
          price: 45000000.0,
          imageUrl: 'macbook.png',
          category: 'Laptop',
        ),
      ]));
    }
  }

  void main() {
    test('ProductListNotifier filters products correctly based on searchQuery', () async {
      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(FakeProductRepository()),
        ],
      );
      addTearDown(container.dispose);

      // Wait for stream value to load
      await container.read(productListNotifierProvider.notifier).stream.first;

      final allProducts = container.read(filteredProductsProvider).value;
      expect(allProducts?.length, 2);

      // Filter by 'iphone'
      container.read(productListNotifierProvider.notifier).updateSearchQuery('iphone');
      final filtered = container.read(filteredProductsProvider).value;
      expect(filtered?.length, 1);
      expect(filtered?.first.name, 'Điện thoại iPhone');
    });
  }
  ```

- [ ] **Step 2: Implement ProductListState**
  Create `lib/features/products/presentation/controllers/product_list_state.dart`:
  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../domain/entities/product.dart';

  part 'product_list_state.freezed.dart';

  @freezed
  class ProductListState with _$ProductListState {
    const factory ProductListState({
      @Default('') String searchQuery,
      @Default(AsyncValue.loading()) AsyncValue<List<Product>> products,
    }) = _ProductListState;
  }
  ```

- [ ] **Step 3: Implement ProductListNotifier and Providers**
  Create `lib/features/products/presentation/controllers/product_list_notifier.dart`:
  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:fpdart/fpdart.dart';
  import '../../domain/entities/product.dart';
  import '../../domain/usecases/watch_products_usecase.dart';
  import 'product_list_state.dart';
  import '../../../core/providers/firebase_providers.dart';
  import '../../data/datasources/product_remote_datasource.dart';
  import '../../data/repositories/product_repository_impl.dart';
  import '../../domain/repositories/product_repository.dart';

  final productRepositoryProvider = Provider<ProductRepository>((ref) {
    final firestore = ref.watch(firestoreProvider);
    return ProductRepositoryImpl(ProductRemoteDataSource(firestore));
  });

  final watchProductsUseCaseProvider = Provider<WatchProductsUseCase>((ref) {
    return WatchProductsUseCase(ref.watch(productRepositoryProvider));
  });

  class ProductListNotifier extends StateNotifier<ProductListState> {
    final WatchProductsUseCase _watchProductsUseCase;

    ProductListNotifier(this._watchProductsUseCase) : super(const ProductListState()) {
      _init();
    }

    void _init() {
      _watchProductsUseCase.execute().listen((result) {
        result.fold(
          (error) => state = state.copyWith(products: AsyncValue.error(error, StackTrace.current)),
          (list) => state = state.copyWith(products: AsyncValue.data(list)),
        );
      });
    }

    void updateSearchQuery(String query) {
      state = state.copyWith(searchQuery: query);
    }
  }

  final productListNotifierProvider =
      StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
    return ProductListNotifier(ref.watch(watchProductsUseCaseProvider));
  });

  final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
    final state = ref.watch(productListNotifierProvider);
    return state.products.whenData((products) {
      if (state.searchQuery.trim().isEmpty) return products;
      
      final query = state.searchQuery.toLowerCase().trim();
      return products.where((product) {
        return product.name.toLowerCase().contains(query) ||
               product.description.toLowerCase().contains(query);
      }).toList();
    });
  });
  ```

- [ ] **Step 4: Run build_runner to generate state freezer classes**
  Run: `flutter pub run build_runner build --delete-conflicting-outputs`
  Expected: Clean build success with `product_list_state.freezed.dart` generated.

- [ ] **Step 5: Run tests to verify they pass**
  Run: `flutter test test/features/products/presentation/controllers/product_list_notifier_test.dart`
  Expected: PASS

- [ ] **Step 6: Commit Presentation controllers changes**
  Run: `git add lib/features/products/presentation/controllers/ test/features/products/presentation/controllers/`
  Run: `git commit -m "feat(products): Implement ProductListState, Notifier, and providers"`

---

### Task 4: UI Presentation Layer (ProductCard Widget & HomeScreen Integration)

**Files:**
* Create: `lib/features/products/presentation/views/widgets/product_card.dart`
* Modify: `lib/features/home/presentation/views/home_screen.dart`
* Create: `test/features/products/presentation/views/widgets/product_card_test.dart`
* Create: `test/features/home/presentation/views/home_screen_test.dart`

**Interfaces:**
* Consumes: `Product` entity, `filteredProductsProvider` stream provider, `productListNotifierProvider` notifier provider.

- [ ] **Step 1: Write Widget test for ProductCard**
  Create `test/features/products/presentation/views/widgets/product_card_test.dart`:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:toy_app/features/products/domain/entities/product.dart';
  import 'package:toy_app/features/products/presentation/views/widgets/product_card.dart';

  void main() {
    testWidgets('ProductCard renders product details', (tester) async {
      const product = Product(
        id: 'p1',
        name: 'Điện thoại iPhone 15',
        description: 'iPhone 15 Pro Max',
        price: 25000000.0,
        imageUrl: 'iphone15.png',
        category: 'Điện thoại',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductCard(product: product),
          ),
        ),
      );

      expect(find.text('Điện thoại iPhone 15'), findsOneWidget);
      expect(find.text('Điện thoại'), findsOneWidget);
      expect(find.text('25.000.000đ'), findsOneWidget);
    });
  }
  ```

- [ ] **Step 2: Implement ProductCard widget**
  Create `lib/features/products/presentation/views/widgets/product_card.dart`:
  ```dart
  import 'package:flutter/material.dart';
  import '../../domain/entities/product.dart';

  class ProductCard extends StatelessWidget {
    final Product product;

    const ProductCard({super.key, required this.product});

    @override
    Widget build(BuildContext context) {
      final priceStr = '${product.price.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          )}đ';

      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.blue.shade50,
                    child: const Icon(Icons.image, size: 40, color: Colors.blue),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priceStr,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
  ```

- [ ] **Step 3: Run ProductCard widget test**
  Run: `flutter test test/features/products/presentation/views/widgets/product_card_test.dart`
  Expected: PASS

- [ ] **Step 4: Write Widget test for HomeScreen with Search**
  Create `test/features/home/presentation/views/home_screen_test.dart`:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:toy_app/features/home/presentation/views/home_screen.dart';
  import 'package:toy_app/features/products/presentation/controllers/product_list_notifier.dart';
  import 'package:toy_app/features/products/domain/entities/product.dart';

  void main() {
    testWidgets('HomeScreen renders search input and products list', (tester) async {
      final mockProducts = [
        const Product(
          id: 'p1',
          name: 'Điện thoại iPhone',
          description: 'Mô tả',
          price: 15000000.0,
          imageUrl: 'iphone.png',
          category: 'Điện thoại',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            filteredProductsProvider.overrideWithValue(AsyncValue.data(mockProducts)),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Tìm kiếm sản phẩm...'), findsOneWidget);
      expect(find.text('Điện thoại iPhone'), findsOneWidget);
    });
  }
  ```

- [ ] **Step 5: Modify HomeScreen to integrate Search and Products**
  Modify `lib/features/home/presentation/views/home_screen.dart`:
  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../../auth/presentation/controllers/auth_action_controller.dart';
  import '../../../auth/presentation/views/profile_screen.dart';
  import '../../products/presentation/controllers/product_list_notifier.dart';
  import '../../products/presentation/views/widgets/product_card.dart';

  class HomeScreen extends ConsumerStatefulWidget {
    const HomeScreen({super.key});

    @override
    ConsumerState<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends ConsumerState<HomeScreen> {
    late final TextEditingController _searchController;

    @override
    void initState() {
      super.initState();
      _searchController = TextEditingController();
    }

    @override
    void dispose() {
      _searchController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final productsState = ref.watch(filteredProductsProvider);
      final searchVal = ref.watch(productListNotifierProvider).searchQuery;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Đồ Điện Tử'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text('Bạn có chắc muốn đăng xuất?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Hủy'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await ref.read(authActionControllerProvider.notifier).signOut();
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref.read(productListNotifierProvider.notifier).updateSearchQuery(val);
                },
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchVal.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(productListNotifierProvider.notifier).updateSearchQuery('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
              ),
            ),
            Expanded(
              child: productsState.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy sản phẩm nào.'),
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    },
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
  }
  ```

- [ ] **Step 6: Run HomeScreen widget test**
  Run: `flutter test test/features/home/presentation/views/home_screen_test.dart`
  Expected: PASS

- [ ] **Step 7: Run all tests in the codebase**
  Run: `flutter test`
  Expected: PASS (0 failures)

- [ ] **Step 8: Run analyzer to ensure clean code**
  Run: `flutter analyze`
  Expected: No issues found.

- [ ] **Step 9: Commit UI changes**
  Run: `git add lib/features/products/presentation/views/ lib/features/home/ test/features/products/presentation/views/ test/features/home/`
  Run: `git commit -m "feat(ui): Integrate product list and search bar into HomeScreen"`
