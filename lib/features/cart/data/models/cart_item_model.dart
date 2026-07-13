import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String productId;
  final int quantity;
  final DateTime? addedAt;

  const CartItemModel({
    required this.productId,
    required this.quantity,
    this.addedAt,
  });

  factory CartItemModel.fromFirestore(String productId, Map<String, dynamic> data) {
    final addedAtRaw = data['addedAt'];
    DateTime? addedAtDate;
    if (addedAtRaw is Timestamp) {
      addedAtDate = addedAtRaw.toDate();
    }
    return CartItemModel(
      productId: productId,
      quantity: (data['quantity'] ?? 1) as int,
      addedAt: addedAtDate,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'quantity': quantity,
      'addedAt': addedAt ?? FieldValue.serverTimestamp(),
    };
  }
}
