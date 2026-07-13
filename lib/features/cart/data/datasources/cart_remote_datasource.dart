import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';

abstract interface class CartRemoteDataSource {
  Stream<List<CartItemModel>> watchCart(String userId);
  Future<void> addToCart(String userId, String productId, int quantity);
  Future<void> updateQuantity(String userId, String productId, int quantity);
  Future<void> removeFromCart(String userId, String productId);
  Future<void> clearCart(String userId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final FirebaseFirestore _firestore;

  CartRemoteDataSourceImpl(this._firestore);

  CollectionReference _cartCol(String userId) =>
      _firestore.collection('users/$userId/cart');

  @override
  Stream<List<CartItemModel>> watchCart(String userId) {
    return _cartCol(userId).snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CartItemModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  @override
  Future<void> addToCart(String userId, String productId, int quantity) async {
    final doc = _cartCol(userId).doc(productId);
    final snapshot = await doc.get();
    if (snapshot.exists) {
      final currentQty = (snapshot.data() as Map<String, dynamic>?)?['quantity'] ?? 0;
      await doc.update({'quantity': currentQty + quantity});
    } else {
      await doc.set(CartItemModel(productId: productId, quantity: quantity).toFirestore());
    }
  }

  @override
  Future<void> updateQuantity(String userId, String productId, int quantity) async {
    await _cartCol(userId).doc(productId).update({'quantity': quantity});
  }

  @override
  Future<void> removeFromCart(String userId, String productId) async {
    await _cartCol(userId).doc(productId).delete();
  }

  @override
  Future<void> clearCart(String userId) async {
    final snapshot = await _cartCol(userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
