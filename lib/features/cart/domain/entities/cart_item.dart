import 'package:toy_app/features/products/domain/entities/product.dart';

class CartItem {
  final String productId;
  final Product product;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.product,
    required this.quantity,
  });
}
