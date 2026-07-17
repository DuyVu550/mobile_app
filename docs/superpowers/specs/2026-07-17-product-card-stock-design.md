# Spec: Display Stock Count on Product Card

This spec outlines the addition of the remaining stock count to the Product Card component.

## Scope & Goal
Display "Còn lại: <quantity>" or "Hết hàng" on each product card, below the category and above the price.

## Proposed Changes

### Product Card UI Change
- File: [product_card.dart](file:///d:/mobile_app/lib/features/products/presentation/views/widgets/product_card.dart)
- Design:
  ```dart
  Text(
    product.stock > 0 ? 'Còn lại: ${product.stock}' : 'Hết hàng',
    style: TextStyle(
      color: product.stock > 0 ? Colors.green.shade700 : Colors.redAccent,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  )
  ```
  This is inserted between the category widget and the price Row, with appropriate spacing.

### Product Card Test Change
- File: [product_card_test.dart](file:///d:/mobile_app/test/features/products/presentation/views/widgets/product_card_test.dart)
- Assertion:
  Verify that the widget containing the text `'Còn lại: 10'` is rendered.
