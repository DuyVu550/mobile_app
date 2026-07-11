# Design Specification: Sub-category Sections Display Feature
**Date:** 2026-07-11
**Topic:** Display toys grouped by sub-categories (Brands, Age Groups, Genders) in dedicated horizontal scrollable sections on the home screen.

---

## 1. Goal
Provide a rich, organized, and modern e-commerce landing experience on the main `ToyListScreen` by grouping and presenting toy products under their specific sub-categories (brands, age groups, and genders). When no filters are active, the landing page displays horizontal lists of toys for selected sub-categories. When search or filters are active, it transitions back to a clean list view of the filtered results.

---

## 2. Requirements & UX Flow
* **Homepage Mode (Default)**: Active when there are no active filters (search query is empty, brand/age/gender filters are empty). Shows:
  * **Featured Slider** at the top.
  * **Brand Section**: A horizontal scroll of brand avatars. Below it, a horizontal scroll of toys belonging to the selected brand (defaulting to the first available brand).
  * **Age Group Section**: A horizontal scroll of age group chips. Below it, a horizontal scroll of toys belonging to the selected age group (defaulting to the first available age group).
  * **Gender Section**: A horizontal scroll of gender chips (Bé trai, Bé gái, Cả hai). Below it, a horizontal scroll of toys belonging to the selected gender (defaulting to the first available gender).
  * **General Catalog**: A vertical list of all toys as suggestions.
* **Search/Filter Mode**: Active when search query or filters from the main filter bar are applied. In this mode, the subcategory horizontal sections are hidden, and a single vertical list/grid showing only the matching products is rendered.
* **Interactive Elements**:
  * Tapping on a brand/age/gender in the section selector updates the selected category for that section and dynamically re-filters the horizontal toy list below it.
  * Tapping on a product card navigates to the detailed product view (`ToyDetailScreen`).

---

## 3. Proposed Changes

### A. Presentation Layer (State & UI)
1. **[NEW] Section State Providers** (`lib/features/toy_list/presentation/controllers/toy_list_notifier.dart`)
   * Add:
     * `selectedBrandSectionProvider` (`StateProvider<String>`): Tracks the active brand in the Brand section.
     * `selectedAgeSectionProvider` (`StateProvider<String>`): Tracks the active age group in the Age Group section.
     * `selectedGenderSectionProvider` (`StateProvider<String>`): Tracks the active gender in the Gender section.
2. **[NEW] Premium Toy Card** (`lib/features/toy_list/presentation/views/widgets/toy_card.dart`)
   * Add a generic card widget (`ToyCard`) for displaying toys in the horizontal lists:
     * Card container with shadow and rounded corners.
     * Image loaded from URL (`imageUrl`) with loading & error fallbacks.
     * Title, tag, price, and tap interaction.
3. **[MODIFY] Homepage Layout** (`lib/features/toy_list/presentation/views/toy_list_screen.dart`)
   * Update screen body:
     * Detect if any filter is active using `toyFilterProvider` (check if `query`, `brand`, `ageGroup`, or `gender` is not empty).
     * If filters are active, render the filtered list of toys as a vertical list/grid (Filter/Search Mode).
     * If no filters are active, render the rich categorized homepage with the horizontal sections and cards.

---

## 4. Verification Plan
* **Visual Check**: Run the Flutter app in Chrome and verify the layout, section headings, chips, and horizontal scroll views.
* **Interactive Filtering**: Tap on different brands/age groups/genders in the section selectors and ensure the products update instantly.
* **Search/Filter Transition**: Enter text into the search bar or select options in the top filter bar, and verify that the homepage sections are hidden and only the filtered list is displayed.
* **Unit/Widget Tests**: Update or add widget tests to verify that the home screen displays the sub-category sections when filters are empty.
