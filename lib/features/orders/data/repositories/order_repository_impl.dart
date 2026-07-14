import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepositoryImpl(this._firestore);

  @override
  Stream<List<OrderEntity>> watchUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderEntity.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Stream<List<OrderEntity>> watchAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderEntity.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({'status': status});
  }

  @override
  Future<void> submitOrder(OrderEntity order) async {
    final orderRef = _firestore.collection('orders').doc();
    final batch = _firestore.batch();
    
    batch.set(orderRef, order.toJson());
    
    // Clear user cart
    final cartSnapshot = await _firestore.collection('users/${order.userId}/cart').get();
    for (final doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  @override
  Future<void> submitDeliveryReview(String orderId, int rating, String comment) async {
    await _firestore.collection('orders').doc(orderId).update({
      'deliveryRating': rating,
      'deliveryComment': comment,
    });
  }
}
