# Design Specification: Product Search by Name (Keyword)
**Date:** 2026-07-12
**Topic:** Product Search by Name (keyword) with Firestore-backed real-time database and Client-side Filtering

---

## 1. Goal
Implement a real-time product search feature by name (keyword) directly on the main `HomeScreen`. This will serve as the foundation of the electronics product catalog. The products will be loaded in real-time from a `/products` Firestore collection, and matching will be performed client-side to allow fast, flexible, accent-insensitive search queries.

---

## 2. Requirements & UX Flow
* **Data Source:** Realtime stream of products from Firestore collection `/products`.
* **UI Location:** Top of `HomeScreen`, below the AppBar.
* **UI Components:**
  * A search text field (`TextField` or `SearchBar`) with a search icon at the beginning and a clear button at the end when text is present.
  * A GridView or ListView displaying matching products below.
  * If no products match the keyword, display a clear, user-friendly "Không tìm thấy sản phẩm nào" message.
* **Search Matching Logic:**
  * Accent-insensitive & case-insensitive matching.
  * Checks if the product name contains the search keyword.
  * If the search field is empty, displays all products.

---

## 3. Proposed Changes

### A. Domain Layer
1. **[NEW] `Product` Entity** (`lib/features/products/domain/entities/product.dart`)
   * Fields: `id`, `name`, `description`, `price`, `imageUrl`, `category`.
2. **[NEW] `ProductRepository` Interface** (`lib/features/products/domain/repositories/product_repository.dart`)
   * `Stream<Either<String, List<Product>>> watchProducts();`
3. **[NEW] `WatchProductsUseCase`** (`lib/features/products/domain/usecases/watch_products_usecase.dart`)
   * Exposes `watchProducts()` from the repository.

### B. Data Layer
1. **[NEW] `ProductModel`** (`lib/features/products/data/models/product_model.dart`)
   * Freezed data class implementing `Product`.
   * Implements `fromJson`, `toJson`, and `fromFirestore`.
2. **[NEW] `ProductRemoteDataSource`** (`lib/features/products/data/datasources/product_remote_datasource.dart`)
   * Subscribes to `/products` collection snapshots in Firestore, sorted by name.
3. **[NEW] `ProductRepositoryImpl`** (`lib/features/products/data/repositories/product_repository_impl.dart`)
   * Concrete implementation of `ProductRepository` mapping `ProductModel` to `Product`.

### C. Presentation Layer (State & UI)
1. **[NEW] `ProductListState`** (`lib/features/products/presentation/controllers/product_list_state.dart`)
   * Freezed state containing `searchQuery` (String) and `products` (AsyncValue<List<Product>>).
2. **[NEW] `ProductListNotifier`** (`lib/features/products/presentation/controllers/product_list_notifier.dart`)
   * StateNotifier holding `ProductListState`.
   * Listens to the products stream and handles filtering logic based on `searchQuery`.
   * Exposes providers: `productRepositoryProvider`, `watchProductsUseCaseProvider`, and `productListNotifierProvider`.
3. **[NEW] `ProductCard`** (`lib/features/products/presentation/views/widgets/product_card.dart`)
   * Card showing the product image, name, category, and price (formatted to VND).
4. **[MODIFY] `HomeScreen`** (`lib/features/home/presentation/views/home_screen.dart`)
   * Replaced with a layout featuring:
     * Search bar input at the top.
     * GridView of products below it.
     * Integrates with `productListNotifierProvider`.

---

## 4. Verification Plan

### Automated Tests
* **Unit/Notifier Tests**:
  * Verify that filtering logic matches search keyword correctly (case-insensitive, accent-insensitive).
  * Verify that when search query is empty, all products are returned.
* **Widget Tests**:
  * Verify search bar is rendered on `HomeScreen`.
  * Verify that typing in search bar updates state and filters the GridView.
  * Verify the "no results found" UI is shown when no items match.

### Manual Verification
* Deploy mock items to Firestore collection `/products` (e.g., "Điện thoại iPhone 15", "Laptop MacBook Pro", "iPad Pro").
* Verify on emulator that entering search query (e.g. "iphone" or "macbook" or "ipad") displays only the matched products in real time.
