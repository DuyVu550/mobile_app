# Design Specification: Real-time Product Categories Tabs
**Date:** 2026-07-12
**Topic:** Real-time product category filtering via horizontal tab bar (ChoiceChips) on the main HomeScreen.

---

## 1. Goal
Implement a real-time product category filter feature. The products, fetched in real-time from Firestore, will be divided into different categories (e.g., phone, laptop, tablet, etc.). Each category will correspond to a tab on the main `HomeScreen`. Users can click on a tab to filter the product list in real-time. The list of categories will be extracted dynamically from the fetched products to avoid hardcoding.

---

## 2. Requirements & UX Flow
* **Data Source:** Realtime stream of products from Firestore collection `/products`.
* **Category Tabs Determination:** 
  * Extracted dynamically from the `category` field of all currently available products in the Firestore database.
  * An `'Tất cả'` (All) tab is added at the very beginning of the tab list.
  * Sorted alphabetically (except `'Tất cả'` which is always first).
* **UI Location:** Top of `HomeScreen`, below the search field and above the products grid.
* **UI Components:**
  * A horizontal scrollable list (`SingleChildScrollView` + `Row`) of ChoiceChips displaying each category name.
  * Highlight the selected category.
* **Interaction & Filtering Logic:**
  * When a category is tapped, update the selected category state.
  * The product grid will display only products matching both the active tab and the current search keyword (if any).
  * **Featured Product Slider:** Only visible when the `'Tất cả'` (All) tab is active. If any other category tab is active, the slider is hidden.

---

## 3. Proposed Changes

### A. Presentation Layer (State & UI)
1. **[MODIFY] `ProductListState`** (`lib/features/products/presentation/controllers/product_list_state.dart`)
   * Add a new field: `String selectedCategory` (defaults to `'Tất cả'`).

2. **[MODIFY] `ProductListNotifier`** (`lib/features/products/presentation/controllers/product_list_notifier.dart`)
   * Add method `void selectCategory(String category)` to update `selectedCategory` state.
   * **[NEW] `categoriesProvider`**: A provider that extracts unique, sorted categories from `state.products` and prepends `'Tất cả'`.
   * **[MODIFY] `filteredProductsProvider`**: Update to filter the product list by BOTH `searchQuery` and `selectedCategory` (if `selectedCategory` is not `'Tất cả'`).

3. **[MODIFY] `HomeScreen`** (`lib/features/home/presentation/views/home_screen.dart`)
   * Add a horizontal category tab bar using `ChoiceChip` widgets.
   * Listen to `categoriesProvider` to dynamically render categories.
   * Listen to `selectedCategory` from `productListNotifierProvider` to highlight the selected ChoiceChip.
   * Conditionally render `FeaturedProductSlider` only when `'Tất cả'` is selected.
   * Display filtered products matching the selected tab.

---

## 4. Verification Plan

### Automated Tests
* **Unit/Notifier Tests** (`test/features/products/presentation/controllers/product_list_notifier_test.dart`):
   * Verify `categoriesProvider` correctly extracts unique categories and prepends `'Tất cả'`.
   * Verify changing category updates `selectedCategory` state.
   * Verify `filteredProductsProvider` returns only products matching the selected category when it's not `'Tất cả'`.
   * Verify combined search and category filtering logic.

### Manual Verification
* Run the app in debug mode on Chrome or Emulator.
* In Firestore, add a product with a new category (e.g. `'Tivi'`). Verify that the `'Tivi'` tab appears immediately and dynamically.
* Tap different category tabs (e.g. `'laptop'`, `'phone'`) and verify that:
  * Only products matching that category are displayed in the grid.
  * The `FeaturedProductSlider` is hidden.
* Tap `'Tất cả'` tab and verify that:
  * All products are shown.
  * The `FeaturedProductSlider` is visible again.
