import '../entities/order_entity.dart';

abstract class OrderRepository {
  Stream<List<OrderEntity>> watchUserOrders(String userId);
  Stream<List<OrderEntity>> watchAllOrders();
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> submitOrder(OrderEntity order);
  Future<void> submitDeliveryReview(String orderId, int rating, String comment);
}
