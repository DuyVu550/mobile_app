import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/toy.dart';
import '../../domain/usecases/get_toys_usecase.dart';
import '../../domain/usecases/watch_brands_usecase.dart';
import '../../domain/entities/brand.dart';
import '../../data/datasources/toy_remote_datasource.dart';
import '../../data/repositories/toy_repository_impl.dart';
import '../../domain/repositories/toy_repository.dart';
import '../../../../core/providers/firebase_providers.dart';
import 'toy_list_state.dart';

// Dependency Injection Providers
final toyRemoteDataSourceProvider = Provider<ToyRemoteDataSource>((ref) {
  return ToyRemoteDataSource(ref.watch(firestoreProvider));
});

final toyRepositoryProvider = Provider<ToyRepository>((ref) {
  final dataSource = ref.watch(toyRemoteDataSourceProvider);
  return ToyRepositoryImpl(dataSource);
});

final watchToysUseCaseProvider = Provider<WatchToysUseCase>((ref) {
  return WatchToysUseCase(ref.watch(toyRepositoryProvider));
});

final watchBrandsUseCaseProvider = Provider<WatchBrandsUseCase>((ref) {
  return WatchBrandsUseCase(ref.watch(toyRepositoryProvider));
});

final getToyByIdUseCaseProvider = Provider<GetToyByIdUseCase>((ref) {
  return GetToyByIdUseCase(ref.watch(toyRepositoryProvider));
});

/// Nguồn realtime duy nhất: mọi thứ (danh sách, tùy chọn lọc) derive từ đây.
final toysStreamProvider =
    StreamProvider<Either<String, List<Toy>>>((ref) {
  return ref.watch(watchToysUseCaseProvider).execute();
});

/// Bộ lọc client-side. Rỗng nghĩa là không lọc theo tiêu chí đó.
class ToyFilter {
  final String query;
  final String brand;
  final String ageGroup;
  final String gender;

  const ToyFilter({
    this.query = '',
    this.brand = '',
    this.ageGroup = '',
    this.gender = '',
  });

  ToyFilter copyWith({
    String? query,
    String? brand,
    String? ageGroup,
    String? gender,
  }) {
    return ToyFilter(
      query: query ?? this.query,
      brand: brand ?? this.brand,
      ageGroup: ageGroup ?? this.ageGroup,
      gender: gender ?? this.gender,
    );
  }
}

final toyFilterProvider =
    StateProvider<ToyFilter>((ref) => const ToyFilter());

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

final ageGroupOptionsProvider = Provider<List<String>>((ref) {
  return _distinct(ref, (t) => t.ageGroup);
});

final genderOptionsProvider = Provider<List<String>>((ref) {
  return _distinct(ref, (t) => t.gender);
});

List<String> _distinct(Ref ref, String Function(Toy) selector) {
  final toys = ref.watch(toysStreamProvider).valueOrNull?.fold(
        (_) => const <Toy>[],
        (list) => list,
      ) ??
      const <Toy>[];
  final values = toys.map(selector).where((v) => v.isNotEmpty).toSet().toList()
    ..sort();
  return values;
}

// Notifier Provider
final toyListNotifierProvider =
    AutoDisposeNotifierProvider<ToyListNotifier, ToyListState>(() {
  return ToyListNotifier();
});

class ToyListNotifier extends AutoDisposeNotifier<ToyListState> {
  @override
  ToyListState build() {
    final filter = ref.watch(toyFilterProvider);
    final async = ref.watch(toysStreamProvider);
    return async.when(
      loading: () => const ToyListState.loading(),
      error: (e, _) => ToyListState.error(e.toString()),
      data: (either) => either.fold(
        (error) => ToyListState.error(error),
        (toys) => ToyListState.success(_applyFilter(toys, filter)),
      ),
    );
  }

  /// Tải lại dữ liệu (nút Retry).
  void reload() => ref.invalidate(toysStreamProvider);

  void search(String query) => _set((f) => f.copyWith(query: query));
  void filterByBrand(String brand) => _set((f) => f.copyWith(brand: brand));
  void filterByAgeGroup(String age) => _set((f) => f.copyWith(ageGroup: age));
  void filterByGender(String gender) => _set((f) => f.copyWith(gender: gender));
  void clearFilters() =>
      ref.read(toyFilterProvider.notifier).state = const ToyFilter();

  void _set(ToyFilter Function(ToyFilter) update) {
    final notifier = ref.read(toyFilterProvider.notifier);
    notifier.state = update(notifier.state);
  }

  List<Toy> _applyFilter(List<Toy> toys, ToyFilter filter) {
    final keyword = filter.query.trim().toLowerCase();
    return toys.where((toy) {
      if (keyword.isNotEmpty && !toy.name.toLowerCase().contains(keyword)) {
        return false;
      }
      if (filter.brand.isNotEmpty && toy.brand != filter.brand) return false;
      if (filter.ageGroup.isNotEmpty && toy.ageGroup != filter.ageGroup) {
        return false;
      }
      if (filter.gender.isNotEmpty && toy.gender != filter.gender) return false;
      return true;
    }).toList();
  }
}
