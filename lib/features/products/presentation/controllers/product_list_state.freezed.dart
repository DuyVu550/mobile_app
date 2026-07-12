// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProductListState {
  String get searchQuery => throw _privateConstructorUsedError;
  String get selectedCategory => throw _privateConstructorUsedError;
  AsyncValue<List<Product>> get products => throw _privateConstructorUsedError;
  double? get minPrice => throw _privateConstructorUsedError;
  double? get maxPrice => throw _privateConstructorUsedError;
  double? get minRating => throw _privateConstructorUsedError;
  bool get onlyPromotions => throw _privateConstructorUsedError;

  /// Create a copy of ProductListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductListStateCopyWith<ProductListState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductListStateCopyWith<$Res> {
  factory $ProductListStateCopyWith(
    ProductListState value,
    $Res Function(ProductListState) then,
  ) = _$ProductListStateCopyWithImpl<$Res, ProductListState>;
  @useResult
  $Res call({
    String searchQuery,
    String selectedCategory,
    AsyncValue<List<Product>> products,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool onlyPromotions,
  });
}

/// @nodoc
class _$ProductListStateCopyWithImpl<$Res, $Val extends ProductListState>
    implements $ProductListStateCopyWith<$Res> {
  _$ProductListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = null,
    Object? selectedCategory = null,
    Object? products = null,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? minRating = freezed,
    Object? onlyPromotions = null,
  }) {
    return _then(
      _value.copyWith(
            searchQuery: null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String,
            selectedCategory: null == selectedCategory
                ? _value.selectedCategory
                : selectedCategory // ignore: cast_nullable_to_non_nullable
                      as String,
            products: null == products
                ? _value.products
                : products // ignore: cast_nullable_to_non_nullable
                      as AsyncValue<List<Product>>,
            minPrice: freezed == minPrice
                ? _value.minPrice
                : minPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            maxPrice: freezed == maxPrice
                ? _value.maxPrice
                : maxPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            minRating: freezed == minRating
                ? _value.minRating
                : minRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            onlyPromotions: null == onlyPromotions
                ? _value.onlyPromotions
                : onlyPromotions // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductListStateImplCopyWith<$Res>
    implements $ProductListStateCopyWith<$Res> {
  factory _$$ProductListStateImplCopyWith(
    _$ProductListStateImpl value,
    $Res Function(_$ProductListStateImpl) then,
  ) = __$$ProductListStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String searchQuery,
    String selectedCategory,
    AsyncValue<List<Product>> products,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool onlyPromotions,
  });
}

/// @nodoc
class __$$ProductListStateImplCopyWithImpl<$Res>
    extends _$ProductListStateCopyWithImpl<$Res, _$ProductListStateImpl>
    implements _$$ProductListStateImplCopyWith<$Res> {
  __$$ProductListStateImplCopyWithImpl(
    _$ProductListStateImpl _value,
    $Res Function(_$ProductListStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = null,
    Object? selectedCategory = null,
    Object? products = null,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? minRating = freezed,
    Object? onlyPromotions = null,
  }) {
    return _then(
      _$ProductListStateImpl(
        searchQuery: null == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String,
        selectedCategory: null == selectedCategory
            ? _value.selectedCategory
            : selectedCategory // ignore: cast_nullable_to_non_nullable
                  as String,
        products: null == products
            ? _value.products
            : products // ignore: cast_nullable_to_non_nullable
                  as AsyncValue<List<Product>>,
        minPrice: freezed == minPrice
            ? _value.minPrice
            : minPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        maxPrice: freezed == maxPrice
            ? _value.maxPrice
            : maxPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        minRating: freezed == minRating
            ? _value.minRating
            : minRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        onlyPromotions: null == onlyPromotions
            ? _value.onlyPromotions
            : onlyPromotions // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$ProductListStateImpl implements _ProductListState {
  const _$ProductListStateImpl({
    this.searchQuery = '',
    this.selectedCategory = 'Tất cả',
    this.products = const AsyncValue.loading(),
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.onlyPromotions = false,
  });

  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final String selectedCategory;
  @override
  @JsonKey()
  final AsyncValue<List<Product>> products;
  @override
  final double? minPrice;
  @override
  final double? maxPrice;
  @override
  final double? minRating;
  @override
  @JsonKey()
  final bool onlyPromotions;

  @override
  String toString() {
    return 'ProductListState(searchQuery: $searchQuery, selectedCategory: $selectedCategory, products: $products, minPrice: $minPrice, maxPrice: $maxPrice, minRating: $minRating, onlyPromotions: $onlyPromotions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductListStateImpl &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            (identical(other.products, products) ||
                other.products == products) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.minRating, minRating) ||
                other.minRating == minRating) &&
            (identical(other.onlyPromotions, onlyPromotions) ||
                other.onlyPromotions == onlyPromotions));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    searchQuery,
    selectedCategory,
    products,
    minPrice,
    maxPrice,
    minRating,
    onlyPromotions,
  );

  /// Create a copy of ProductListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductListStateImplCopyWith<_$ProductListStateImpl> get copyWith =>
      __$$ProductListStateImplCopyWithImpl<_$ProductListStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ProductListState implements ProductListState {
  const factory _ProductListState({
    final String searchQuery,
    final String selectedCategory,
    final AsyncValue<List<Product>> products,
    final double? minPrice,
    final double? maxPrice,
    final double? minRating,
    final bool onlyPromotions,
  }) = _$ProductListStateImpl;

  @override
  String get searchQuery;
  @override
  String get selectedCategory;
  @override
  AsyncValue<List<Product>> get products;
  @override
  double? get minPrice;
  @override
  double? get maxPrice;
  @override
  double? get minRating;
  @override
  bool get onlyPromotions;

  /// Create a copy of ProductListState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductListStateImplCopyWith<_$ProductListStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
