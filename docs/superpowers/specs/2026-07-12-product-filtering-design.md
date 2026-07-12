# Design Specification: Product Filtering Feature

This document specifies the design and implementation details for adding product filtering by price range, rating, and promotion status to the mobile application.

## 1. Overview
The product page currently supports filtering by category and searching by keyword. We will enhance this by allowing users to filter products by:
- **Price Range**: Min/Max price with input fields and quick presets.
- **Rating**: Minimum rating (e.g. 4★ & above, 3★ & above).
- **Promotion Status**: Toggle to view only products with active promotions.

The filtering will be performed client-side on the real-time stream of products to ensure instant responses, zero Firestore query index overhead, and compliance with the existing code structure.

---

## 2. Requirements & UI Flow

### UI Entry Point
- A filter icon button (`Icons.filter_list`) will be added to the right of the Search input field on `HomeScreen`.
- If any filters are active (non-default values), the icon will be highlighted in the primary theme color.

### Filter Bottom Sheet (`ProductFilterBottomSheet`)
Users tap the filter button to open a bottom sheet.
1. **Price Filter Section**:
   - **Inputs**: Two numeric input text fields for "Giá tối thiểu" (Min) and "Giá tối đa" (Max).
   - **Presets**: Scrollable chips for quick selection:
     - Under 5M: `[0 - 5M]`
     - 5M to 15M: `[5M - 15M]`
     - Over 15M: `[> 15M]`
     *Tapping a preset fills the inputs.*
2. **Rating Filter Section**:
   - A list of choice chips for minimum stars:
     - `Tất cả` (All)
     - `4★ trở lên` (>= 4.0)
     - `3★ trở lên` (>= 3.0)
3. **Promotion Filter Section**:
   - A switch (`SwitchListTile`) labeled "Chỉ hiện sản phẩm khuyến mãi".
4. **Action Bar**:
   - **Thiết lập lại** (Reset): Clears all inputs and resets state.
   - **Áp dụng** (Apply): Dispatches active state to Riverpod and closes the sheet.

---

## 3. Technical Design

### Data Layer
Add `rating` (double) and `hasPromotion` (bool) to the product model.

#### [domain/entities/product.dart](file:///d:/mobile_app/lib/features/products/domain/entities/product.dart)
```dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isFeatured;
  final double rating;
  final bool hasPromotion;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isFeatured,
    required this.rating,
    required this.hasPromotion,
  });
}
```

#### [data/models/product_model.dart](file:///d:/mobile_app/lib/features/products/data/models/product_model.dart)
```dart
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
    required double rating,
    required bool hasPromotion,
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
      rating: ((data['rating'] ?? 0.0) as num).toDouble(),
      hasPromotion: (data['hasPromotion'] ?? false) as bool,
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
      rating: rating,
      hasPromotion: hasPromotion,
    );
  }
}
```

### State Management
Use Riverpod to manage active filters.

#### [presentation/controllers/product_list_state.dart](file:///d:/mobile_app/lib/features/products/presentation/controllers/product_list_state.dart)
```dart
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
```

#### [presentation/controllers/product_list_notifier.dart](file:///d:/mobile_app/lib/features/products/presentation/controllers/product_list_notifier.dart)
```dart
class ProductListNotifier extends StateNotifier<ProductListState> {
  // ... existing init code ...

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
```

#### Filter logic in `filteredProductsProvider`:
```dart
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final state = ref.watch(productListNotifierProvider);
  return state.products.whenData((products) {
    var list = products;

    // 1. Filter by category
    if (state.selectedCategory != 'Tất cả') {
      list = list.where((p) => p.category == state.selectedCategory).toList();
    }

    // 2. Filter by search query
    if (state.searchQuery.trim().isNotEmpty) {
      final query = removeDiacritics(state.searchQuery.trim());
      list = list.where((product) {
        final name = removeDiacritics(product.name);
        final description = removeDiacritics(product.description);
        return name.contains(query) || description.contains(query);
      }).toList();
    }

    // 3. Filter by price range
    if (state.minPrice != null) {
      list = list.where((p) => p.price >= state.minPrice!).toList();
    }
    if (state.maxPrice != null) {
      list = list.where((p) => p.price <= state.maxPrice!).toList();
    }

    // 4. Filter by minimum rating
    if (state.minRating != null) {
      list = list.where((p) => p.rating >= state.minRating!).toList();
    }

    // 5. Filter by promotions
    if (state.onlyPromotions) {
      list = list.where((p) => p.hasPromotion).toList();
    }

    return list;
  });
});
```

---

## 4. Verification Plan

### Automated Tests
We will add new tests to `product_list_notifier_test.dart` to cover:
1. Filtering products by price range (Min/Max).
2. Filtering products by rating (>= 3.0, >= 4.0).
3. Filtering products by promotion status (onlyPromotions).
4. Combining multiple filters simultaneously.

### Manual Verification
1. Run the app in dev mode.
2. Tap the filter button to open the bottom sheet.
3. Verify that preset price chips populate the min/max fields.
4. Apply price, star rating, and promotion filters individually and together, checking that the displayed products list updates correctly.
5. Tap "Thiết lập lại" (Reset) and check if the original list is restored.
