import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../../core/utils/string_utils.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/watch_products_usecase.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import 'product_list_state.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return ProductRepositoryImpl(ProductRemoteDataSourceImpl(firestore));
});

final watchProductsUseCaseProvider = Provider<WatchProductsUseCase>((ref) {
  return WatchProductsUseCase(ref.watch(productRepositoryProvider));
});

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
}

final productListNotifierProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  return ProductListNotifier(ref.watch(watchProductsUseCaseProvider));
});

/// Danh sách sản phẩm đã lọc theo từ khóa tìm kiếm.
/// Khớp không phân biệt hoa/thường và không phân biệt dấu tiếng Việt.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final state = ref.watch(productListNotifierProvider);
  return state.products.whenData((products) {
    if (state.searchQuery.trim().isEmpty) return products;

    final query = removeDiacritics(state.searchQuery.trim());
    return products.where((product) {
      final name = removeDiacritics(product.name);
      final description = removeDiacritics(product.description);
      return name.contains(query) || description.contains(query);
    }).toList();
  });
});
