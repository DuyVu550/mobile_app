# Design Specification: Product Card & Grid UI Redesign

This document defines the new visual design for the `ProductCard` widget and HomeScreen grid layout to make it look premium and modern.

## 1. Overview
The current product cards on the Home Screen grid are generic and lack interactive styling or a way to navigate to the product detail page upon tapping.
We will redesign `ProductCard` to:
- Adopt a premium, clean card design with soft shadows and custom border treatment.
- Display a "Sale" promotion badge at the top-left of the image if `hasPromotion` is true.
- Display a rating badge (e.g., `★ 4.8`) at the top-right of the image.
- Support navigation to `ProductDetailScreen` when tapped.
- Improve typography (contrast, colors, spacing).

---

## 2. UI / UX Design

### Card Layout
We will replace the generic `Card` widget with a styled `Container`:
- `BorderRadius.circular(16)`
- Soft shadows: `BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))`
- Image fit: `BoxFit.cover` inside a clip region.

### Overlays on Product Image:
1. **Promo Tag** (Top-Left):
   - Background: `Colors.redAccent` with rounded corners.
   - Text: `"Khuyến mãi"` or `"SALE"`.
2. **Rating Badge** (Top-Right):
   - Background: `Colors.black.withOpacity(0.6)` or `Colors.white.withOpacity(0.9)`.
   - Text: `★ 4.8` (amber star).

### Navigation Integration:
- Wrap the entire `ProductCard` in an `InkWell` or `GestureDetector` to push `ProductDetailScreen(product: product)`.

---

## 3. Files

| File | Change |
|------|--------|
| `lib/features/products/presentation/views/widgets/product_card.dart` | REDESIGN |
| `test/features/products/presentation/views/widgets/product_card_test.dart` | UPDATE TESTS |

---

## 4. Verification Plan

### Automated Tests
We will verify that tests compile and the `ProductCard` test passes.
We will add widget tests to verify that tapping a `ProductCard` routes to `ProductDetailScreen`.

### Manual Verification
1. Launch the app.
2. Verify the visual layout of product cards on the HomeScreen.
3. Tap on a product card, and verify it navigates to the detailed view screen correctly.
