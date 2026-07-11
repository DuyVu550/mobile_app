# Design Specification: Brand List & Filter Feature (Firestore-backed)
**Date:** 2026-07-11
**Topic:** Brand List & Filtering with separate Firestore collection and Rich UI

---

## 1. Goal
Implement a rich brand navigation and filtering system on the main `ToyListScreen` using a horizontal scrollable list of circular brand logos. This replaces the basic text-only `FilterChip` implementation. The brand data (names and logo image URLs) will be loaded in real-time from a new `brands` collection in Firestore.

---

## 2. Requirements & UX Flow
* **Data Source:** Realtime stream of brands from Firestore collection `/brands`. Each brand document contains `name` and `imageUrl`.
* **UI Location:** Top of `ToyListScreen`, below the search bar.
* **UI Component:** Horizontal list of circular brand avatars with names below them.
* **Interactions:**
  * Clicking on a brand filters the product list below to display only toys matching `toy.brand == brand.name`.
  * The selected brand displays a visual highlight (e.g. styled border or overlay).
  * Clicking on the selected brand again deselects it, clearing the filter.

---

## 3. Proposed Changes

### A. Domain Layer
1. **[NEW] `Brand` Entity** (`lib/features/toy_list/domain/entities/brand.dart`)
   * Fields: `id`, `name`, `imageUrl`.
2. **[MODIFY] `ToyRepository` Interface** (`lib/features/toy_list/domain/repositories/toy_repository.dart`)
   * Add abstract method: `Stream<Either<String, List<Brand>>> watchBrands();`
3. **[NEW] `WatchBrandsUseCase`** (`lib/features/toy_list/domain/usecases/watch_brands_usecase.dart`)
   * Exposes `watchBrands()` from the repository.

### B. Data Layer
1. **[NEW] `BrandModel`** (`lib/features/toy_list/data/models/brand_model.dart`)
   * Freezed data class implementing `Brand`.
   * Implements `fromJson`, `toJson`, and `fromFirestore`.
2. **[MODIFY] `ToyRemoteDataSource`** (`lib/features/toy_list/data/datasources/toy_remote_datasource.dart`)
   * Add: `Stream<List<BrandModel>> watchBrands();` fetching from Firestore `/brands`.
3. **[MODIFY] `ToyRepositoryImpl`** (`lib/features/toy_list/data/repositories/toy_repository_impl.dart`)
   * Implement `watchBrands()` mapping `BrandModel` list to `Brand` list.

### C. Presentation Layer (State & UI)
1. **[MODIFY] `toy_list_notifier.dart`** (`lib/features/toy_list/presentation/controllers/toy_list_notifier.dart`)
   * Add: `brandsStreamProvider` (watching `WatchBrandsUseCase`).
   * Remove old `brandOptionsProvider` (string-based dynamic extraction).
2. **[MODIFY] `ToyFilterBar`** (`lib/features/toy_list/presentation/views/widgets/toy_filter_bar.dart`)
   * Change brand listing section:
     * Render horizontal list of circular widgets.
     * Render brand logos with `Image.network` and brand name labels underneath.
     * Highlight selected brand with color accents or border.
     * Implement tap toggle logic: Select brand -> Filter by brand; Tap again -> Clear brand filter.

---

## 4. Verification Plan
* **Realtime Verification:** Confirm that editing a brand name or image URL on Firebase console updates the UI in real-time.
* **Filter Functionality:** Verify that clicking a brand displays only toys from that brand, and deselecting returns to full catalog list.
* **Integration/Mock Tests:** Ensure tests compile and run properly with updated repositories and states.
