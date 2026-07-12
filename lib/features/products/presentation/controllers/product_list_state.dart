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
