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

final productListNotifierProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  return ProductListNotifier(ref.watch(watchProductsUseCaseProvider));
});

/// Danh sách danh mục duy nhất được trích xuất động từ sản phẩm,
/// sắp xếp theo bảng chữ cái và luôn có 'Tất cả' ở đầu.
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

/// Danh sách sản phẩm đã lọc theo danh mục và từ khóa tìm kiếm.
/// Khớp không phân biệt hoa/thường và không phân biệt dấu tiếng Việt.
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
