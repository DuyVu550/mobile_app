import '../entities/cart_item.dart';
import '../../data/models/cart_item_model.dart';

abstract interface class CartRepository {
  Stream<List<CartItemModel>> watchCart(String userId);
  Future<void> addToCart(String userId, String productId, int quantity);
  Future<void> updateQuantity(String userId, String productId, int quantity);
  Future<void> removeFromCart(String userId, String productId);
  Future<void> clearCart(String userId);
}
