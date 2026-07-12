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
    double? minPrice,
    double? maxPrice,
    double? minRating,
    @Default(false) bool onlyPromotions,
  }) = _ProductListState;
}
