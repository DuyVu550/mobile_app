import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/toy.dart';
import '../../domain/usecases/get_toys_usecase.dart';
import '../../data/datasources/toy_remote_datasource.dart';
import '../../data/repositories/toy_repository_impl.dart';
import '../../domain/repositories/toy_repository.dart';
import 'toy_list_state.dart';

// Dependency Injection Providers
final toyRemoteDataSourceProvider = Provider<ToyRemoteDataSource>((ref) {
  return ToyRemoteDataSource();
});

final toyRepositoryProvider = Provider<ToyRepository>((ref) {
  final dataSource = ref.watch(toyRemoteDataSourceProvider);
  return ToyRepositoryImpl(dataSource);
});

final getToysUseCaseProvider = Provider<GetToysUseCase>((ref) {
  final repository = ref.watch(toyRepositoryProvider);
  return GetToysUseCase(repository);
});

// Notifier Provider
final toyListNotifierProvider = AutoDisposeNotifierProvider<ToyListNotifier, ToyListState>(() {
  return ToyListNotifier();
});

class ToyListNotifier extends AutoDisposeNotifier<ToyListState> {
  // Full list kept in memory so search can filter without re-fetching.
  List<Toy> _allToys = const [];
  String _query = '';

  @override
  ToyListState build() {
    Future(() => loadToys());
    return const ToyListState.initial();
  }

  Future<void> loadToys() async {
    state = const ToyListState.loading();
    final useCase = ref.read(getToysUseCaseProvider);
    final result = await useCase.execute();
    state = result.fold(
      (error) => ToyListState.error(error),
      (toys) {
        _allToys = toys;
        return ToyListState.success(_applyQuery());
      },
    );
  }

  // Filter the loaded toys by name (case-insensitive keyword match).
  void search(String query) {
    _query = query;
    if (_allToys.isNotEmpty) {
      state = ToyListState.success(_applyQuery());
    }
  }

  List<Toy> _applyQuery() {
    final keyword = _query.trim().toLowerCase();
    if (keyword.isEmpty) return _allToys;
    return _allToys
        .where((toy) => toy.name.toLowerCase().contains(keyword))
        .toList();
  }
}
