# Brand List & Filter Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement rich brand navigation and filtering on the main `ToyListScreen` using a horizontal scroll of circular brand logos loaded from a new `/brands` Firestore collection.

**Architecture:** Extend the feature-first Clean Architecture of the `toy_list` module by adding the `Brand` entity, use case, repository stream, and updating the state management (Riverpod notifier) and UI widgets.

**Tech Stack:** Flutter, Flutter Riverpod, Cloud Firestore, Freezed, fpdart, json_serializable.

## Global Constraints
* Naming conventions: snake_case for files, PascalCase for classes, camelCase with `Provider` suffix for providers.
* Layer isolation: Domain layer must NOT import Flutter, Riverpod, or Data packages.
* Immutability: Use Freezed for models.
* Code analysis: `flutter analyze` must run cleanly.
* Tests: `flutter test` must pass all tests.

---

### Task 1: Domain Layer (Brand Entity, Repository update, UseCase)

**Files:**
* Create: `lib/features/toy_list/domain/entities/brand.dart`
* Modify: `lib/features/toy_list/domain/repositories/toy_repository.dart`
* Create: `lib/features/toy_list/domain/usecases/watch_brands_usecase.dart`
* Create: `test/features/toy_list/domain/usecases/watch_brands_usecase_test.dart`

**Interfaces:**
* Produces: `Brand` class, `watchBrands` repository stream, and `WatchBrandsUseCase`.

- [ ] **Step 1: Write the failing unit test for WatchBrandsUseCase**
  Create `test/features/toy_list/domain/usecases/watch_brands_usecase_test.dart`:
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:fpdart/fpdart.dart';
  import 'package:toy_app/features/toy_list/domain/entities/brand.dart';
  import 'package:toy_app/features/toy_list/domain/repositories/toy_repository.dart';
  import 'package:toy_app/features/toy_list/domain/usecases/watch_brands_usecase.dart';
  import 'package:toy_app/features/toy_list/domain/entities/toy.dart';

  class FakeToyRepository implements ToyRepository {
    @override
    Stream<Either<String, List<Brand>>> watchBrands() async* {
      yield const Right([
        Brand(id: 'b1', name: 'Lego', imageUrl: 'lego.png'),
      ]);
    }

    @override
    Stream<Either<String, List<Toy>>> watchToys() => const Stream.empty();

    @override
    Future<Either<String, Toy>> getToyById(String id) async => Left('Not implemented');
  }

  void main() {
    test('WatchBrandsUseCase should execute and return list of brands', () async {
      final repository = FakeToyRepository();
      final useCase = WatchBrandsUseCase(repository);

      final result = await useCase.execute().first;
      expect(result.isRight(), isTrue);
      result.match(
        (l) => fail('Should be right'),
        (r) {
          expect(r.length, 1);
          expect(r.first.name, 'Lego');
        },
      );
    });
  }
  ```

- [ ] **Step 2: Run test to verify compile failure**
  Run: `flutter test test/features/toy_list/domain/usecases/watch_brands_usecase_test.dart`
  Expected: Compilation fail due to missing Brand, watchBrands, and WatchBrandsUseCase classes.

- [ ] **Step 3: Implement the Domain classes**
  Create `lib/features/toy_list/domain/entities/brand.dart`:
  ```dart
  class Brand {
    final String id;
    final String name;
    final String imageUrl;

    const Brand({
      required this.id,
      required this.name,
      required this.imageUrl,
    });
  }
  ```

  Modify `lib/features/toy_list/domain/repositories/toy_repository.dart`:
  ```dart
  import 'package:fpdart/fpdart.dart';
  import '../entities/toy.dart';
  import '../entities/brand.dart';

  abstract interface class ToyRepository {
    /// Stream danh sách sản phẩm realtime. Phát Left(message) khi có lỗi.
    Stream<Either<String, List<Toy>>> watchToys();

    /// Lấy chi tiết 1 sản phẩm theo id.
    Future<Either<String, Toy>> getToyById(String id);

    /// Stream danh sách thương hiệu đồ chơi realtime.
    Stream<Either<String, List<Brand>>> watchBrands();
  }
  ```

  Create `lib/features/toy_list/domain/usecases/watch_brands_usecase.dart`:
  ```dart
  import 'package:fpdart/fpdart.dart';
  import '../entities/brand.dart';
  import '../repositories/toy_repository.dart';

  class WatchBrandsUseCase {
    final ToyRepository _repository;

    WatchBrandsUseCase(this._repository);

    Stream<Either<String, List<Brand>>> execute() {
      return _repository.watchBrands();
    }
  }
  ```

- [ ] **Step 4: Run test to verify it passes**
  Run: `flutter test test/features/toy_list/domain/usecases/watch_brands_usecase_test.dart`
  Expected: PASS

- [ ] **Step 5: Commit Domain changes**
  ```bash
  git add lib/features/toy_list/domain/ test/features/toy_list/domain/
  git commit -m "feat(toy_list): Add Brand entity, WatchBrandsUseCase, and Repository interface"
  ```

---

### Task 2: Data Layer (BrandModel, RemoteDataSource update, RepositoryImpl update)

**Files:**
* Create: `lib/features/toy_list/data/models/brand_model.dart`
* Modify: `lib/features/toy_list/data/datasources/toy_remote_datasource.dart`
* Modify: `lib/features/toy_list/data/repositories/toy_repository_impl.dart`
* Create: `test/features/toy_list/data/repositories/toy_repository_impl_test.dart`

**Interfaces:**
* Consumes: `Brand` entity, `ToyRepository` interface.
* Produces: `BrandModel` serialized class and concrete repository implementation of `watchBrands()`.

- [ ] **Step 1: Write unit test for ToyRepositoryImpl.watchBrands()**
  Create `test/features/toy_list/data/repositories/toy_repository_impl_test.dart`:
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:toy_app/features/toy_list/data/repositories/toy_repository_impl.dart';
  import 'package:toy_app/features/toy_list/data/datasources/toy_remote_datasource.dart';
  import 'package:toy_app/features/toy_list/data/models/brand_model.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

  class FakeToyRemoteDataSource implements ToyRemoteDataSource {
    @override
    Stream<List<BrandModel>> watchBrands() {
      return Stream.value([
        const BrandModel(id: 'b1', name: 'Lego', imageUrl: 'lego.png'),
      ]);
    }

    @override
    Stream<List<dynamic>> watchToys() => const Stream.empty();

    @override
    Future<dynamic> fetchToyById(String id) async => null;

    @override
    FirebaseFirestore get _firestore => throw UnimplementedError();
  }

  void main() {
    test('ToyRepositoryImpl.watchBrands maps BrandModel to Brand entity', () async {
      final dataSource = FakeToyRemoteDataSource();
      final repository = ToyRepositoryImpl(dataSource);

      final result = await repository.watchBrands().first;
      expect(result.isRight(), isTrue);
      result.match(
        (l) => fail('Should be right'),
        (r) {
          expect(r.length, 1);
          expect(r.first.id, 'b1');
          expect(r.first.name, 'Lego');
          expect(r.first.imageUrl, 'lego.png');
        },
      );
    });
  }
  ```

- [ ] **Step 2: Implement BrandModel and Remote Data Source updates**
  Create `lib/features/toy_list/data/models/brand_model.dart`:
  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';
  import '../../domain/entities/brand.dart';

  part 'brand_model.freezed.dart';
  part 'brand_model.g.dart';

  @freezed
  class BrandModel with _$BrandModel implements Brand {
    const factory BrandModel({
      required String id,
      required String name,
      required String imageUrl,
    }) = _BrandModel;

    const BrandModel._();

    factory BrandModel.fromJson(Map<String, dynamic> json) =>
        _$BrandModelFromJson(json);

    factory BrandModel.fromFirestore(String id, Map<String, dynamic> data) {
      return BrandModel(
        id: id,
        name: (data['name'] ?? '') as String,
        imageUrl: (data['imageUrl'] ?? '') as String,
      );
    }

    Brand toEntity() {
      return Brand(
        id: id,
        name: name,
        imageUrl: imageUrl,
      );
    }
  }
  ```

  Modify `lib/features/toy_list/data/datasources/toy_remote_datasource.dart`:
  ```dart
  import 'package:cloud_firestore/cloud_firestore.dart';
  import '../models/toy_model.dart';
  import '../models/brand_model.dart';

  /// Nguồn dữ liệu sản phẩm đồ chơi realtime từ Firestore.
  ///
  /// Collection `toys`, mỗi document là 1 sản phẩm. Trả stream để UI
  /// tự cập nhật khi dữ liệu trên Firebase thay đổi.
  class ToyRemoteDataSource {
    final FirebaseFirestore _firestore;

    ToyRemoteDataSource(this._firestore);

    static const _collection = 'toys';
    static const _brandsCollection = 'brands';

    /// Stream danh sách sản phẩm, sắp xếp theo tên cho ổn định.
    Stream<List<ToyModel>> watchToys() {
      return _firestore
          .collection(_collection)
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ToyModel.fromFirestore(doc.id, doc.data()))
              .toList());
    }

    /// Lấy chi tiết 1 sản phẩm theo id (null nếu không tồn tại).
    Future<ToyModel?> fetchToyById(String id) async {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return null;
      return ToyModel.fromFirestore(doc.id, doc.data()!);
    }

    /// Stream danh sách thương hiệu đồ chơi realtime từ Firestore.
    Stream<List<BrandModel>> watchBrands() {
      return _firestore
          .collection(_brandsCollection)
          .orderBy('name')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => BrandModel.fromFirestore(doc.id, doc.data()))
              .toList());
    }
  }
  ```

- [ ] **Step 3: Run build_runner to generate BrandModel files**
  Run: `flutter pub run build_runner build --delete-conflicting-outputs`
  Expected: Clean build success with `brand_model.freezed.dart` and `brand_model.g.dart` generated.

- [ ] **Step 4: Implement Repository updates**
  Modify `lib/features/toy_list/data/repositories/toy_repository_impl.dart`:
  ```dart
  import 'package:fpdart/fpdart.dart';
  import '../../domain/entities/toy.dart';
  import '../../domain/entities/brand.dart';
  import '../../domain/repositories/toy_repository.dart';
  import '../datasources/toy_remote_datasource.dart';

  class ToyRepositoryImpl implements ToyRepository {
    final ToyRemoteDataSource _remoteDataSource;

    const ToyRepositoryImpl(this._remoteDataSource);

    @override
    Stream<Either<String, List<Toy>>> watchToys() async* {
      try {
        await for (final models in _remoteDataSource.watchToys()) {
          yield Right(models.map((m) => m.toEntity()).toList());
        }
      } catch (e) {
        yield Left(_mapError(e));
      }
    }

    @override
    Future<Either<String, Toy>> getToyById(String id) async {
      try {
        final model = await _remoteDataSource.fetchToyById(id);
        if (model == null) {
          return const Left('Không tìm thấy sản phẩm.');
        }
        return Right(model.toEntity());
      } catch (e) {
        return Left(_mapError(e));
      }
    }

    @override
    Stream<Either<String, List<Brand>>> watchBrands() async* {
      try {
        await for (final models in _remoteDataSource.watchBrands()) {
          yield Right(models.map((m) => m.toEntity()).toList());
        }
      } catch (e) {
        yield Left('Không tải được danh sách thương hiệu: $e');
      }
    }

    String _mapError(Object e) => 'Không tải được dữ liệu sản phẩm: $e';
  }
  ```

- [ ] **Step 5: Run tests to verify they pass**
  Run: `flutter test test/features/toy_list/data/repositories/toy_repository_impl_test.dart`
  Expected: PASS

- [ ] **Step 6: Commit Data Layer changes**
  ```bash
  git add lib/features/toy_list/data/ test/features/toy_list/data/
  git commit -m "feat(toy_list): Implement BrandModel and watchBrands in repository and datasource"
  ```

---

### Task 3: Presentation Layer & UI (Riverpod Provider updates, ToyFilterBar UI)

**Files:**
* Modify: `lib/features/toy_list/presentation/controllers/toy_list_notifier.dart`
* Modify: `lib/features/toy_list/presentation/views/widgets/toy_filter_bar.dart`
* Create: `test/features/toy_list/presentation/views/widgets/toy_filter_bar_test.dart`

**Interfaces:**
* Consumes: `WatchBrandsUseCase`, `Brand` entity, Riverpod stream providers.
* Produces: Circular brand filter widgets on `ToyListScreen`.

- [ ] **Step 1: Update Riverpod Providers**
  Modify `lib/features/toy_list/presentation/controllers/toy_list_notifier.dart`:
  * Add the provider for `WatchBrandsUseCase`.
  * Replace the old string-based `brandOptionsProvider` with `brandsStreamProvider` and `brandsListProvider` to serve the UI with complete `Brand` entities.
  
  Replace lines 68-70 in `lib/features/toy_list/presentation/controllers/toy_list_notifier.dart`:
  ```dart
  final watchBrandsUseCaseProvider = Provider<WatchBrandsUseCase>((ref) {
    return WatchBrandsUseCase(ref.watch(toyRepositoryProvider));
  });

  /// Nguồn realtime thương hiệu từ Firestore
  final brandsStreamProvider =
      StreamProvider<Either<String, List<Brand>>>((ref) {
    return ref.watch(watchBrandsUseCaseProvider).execute();
  });

  /// Danh sách các thương hiệu đã được bóc tách từ Stream
  final brandsListProvider = Provider<List<Brand>>((ref) {
    return ref.watch(brandsStreamProvider).valueOrNull?.fold(
          (_) => const <Brand>[],
          (list) => list,
        ) ??
        const <Brand>[];
  });
  ```

- [ ] **Step 2: Update ToyFilterBar Widget with circular logos**
  Modify `lib/features/toy_list/presentation/views/widgets/toy_filter_bar.dart`:
  * Read `brandsListProvider` instead of the old string-based `brandOptionsProvider`.
  * Replace `FilterChip` items with a custom scrollable list of circular widgets.
  * Render circular avatars showing brand logo using `Image.network` with a backup placeholder.
  * Render brand name label below the circular avatar.
  * Add a border outline highlight if the brand is currently selected (`filter.brand == brand.name`).
  
  Replace lines 11-45 in `lib/features/toy_list/presentation/views/widgets/toy_filter_bar.dart`:
  ```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brands = ref.watch(brandsListProvider);
    final ages = ref.watch(ageGroupOptionsProvider);
    final genders = ref.watch(genderOptionsProvider);
    final filter = ref.watch(toyFilterProvider);
    final notifier = ref.read(toyListNotifierProvider.notifier);

    final hasAnyFilter = filter.brand.isNotEmpty ||
        filter.ageGroup.isNotEmpty ||
        filter.gender.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (brands.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  final brand = brands[index];
                  final isSelected = filter.brand == brand.name;

                  return GestureDetector(
                    onTap: () => notifier.filterByBrand(isSelected ? '' : brand.name),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.amber : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.3),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: ClipOval(
                              child: Image.network(
                                brand.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.amber.shade100,
                                  child: Center(
                                    child: Text(
                                      brand.name.isNotEmpty ? brand.name[0].toUpperCase() : 'B',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            brand.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.amber.shade800 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
  ```

- [ ] **Step 3: Write Widget tests for the new Brand Filter UI**
  Create `test/features/toy_list/presentation/views/widgets/toy_filter_bar_test.dart`:
  ```dart
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
      expect(find.byType(GestureDetector), findsNWidgets(2));
    });
  }
  ```

- [ ] **Step 4: Run all tests to verify everything is passing**
  Run: `flutter test`
  Expected: All tests pass successfully (0 failures).

- [ ] **Step 5: Run flutter analyze to verify clean code analysis**
  Run: `flutter analyze`
  Expected: No issues found!

- [ ] **Step 6: Commit UI & Presentation Layer changes**
  ```bash
  git add lib/features/toy_list/presentation/ test/features/toy_list/presentation/
  git commit -m "feat(toy_list): Update ToyFilterBar UI with rich circular brand logos and names"
  ```
