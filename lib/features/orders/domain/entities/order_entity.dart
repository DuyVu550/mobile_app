import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemEntity {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    return OrderItemEntity(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class OrderEntity {
  final String id;
  final String userId;
  final String receiverName;
  final String phoneNumber;
  final String addressLine;
  final String paymentMethod;
  final List<OrderItemEntity> items;
  final double totalPrice;
  final double discount;
  final String status; // 'Đang xử lý' | 'Đã hoàn thành'
  final DateTime createdAt;
  final int? deliveryRating;
  final String? deliveryComment;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.receiverName,
    required this.phoneNumber,
    required this.addressLine,
    required this.paymentMethod,
    required this.items,
    required this.totalPrice,
    required this.discount,
    required this.status,
    required this.createdAt,
    this.deliveryRating,
    this.deliveryComment,
  });

  factory OrderEntity.fromJson(String id, Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems.map((item) => OrderItemEntity.fromJson(item as Map<String, dynamic>)).toList();
    
    DateTime parsedDate;
    final rawCreated = json['createdAt'];
    if (rawCreated is Timestamp) {
      parsedDate = rawCreated.toDate();
    } else if (rawCreated is String) {
      parsedDate = DateTime.parse(rawCreated);
    } else {
      parsedDate = DateTime.now();
    }

    return OrderEntity(
      id: id,
      userId: json['userId'] as String? ?? '',
      receiverName: json['receiverName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      addressLine: json['addressLine'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? 'COD',
      items: itemsList,
      totalPrice: (json['totalPrice'] as num? ?? 0.0).toDouble(),
      discount: (json['discount'] as num? ?? 0.0).toDouble(),
      status: json['status'] as String? ?? 'Đang xử lý',
      createdAt: parsedDate,
      deliveryRating: json['deliveryRating'] as int?,
      deliveryComment: json['deliveryComment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'receiverName': receiverName,
      'phoneNumber': phoneNumber,
      'addressLine': addressLine,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'discount': discount,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      if (deliveryRating != null) 'deliveryRating': deliveryRating,
      if (deliveryComment != null) 'deliveryComment': deliveryComment,
    };
  }

  OrderEntity copyWith({
    String? id,
    String? userId,
    String? receiverName,
    String? phoneNumber,
    String? addressLine,
    String? paymentMethod,
    List<OrderItemEntity>? items,
    double? totalPrice,
    double? discount,
    String? status,
    DateTime? createdAt,
    int? deliveryRating,
    String? deliveryComment,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      receiverName: receiverName ?? this.receiverName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine: addressLine ?? this.addressLine,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      discount: discount ?? this.discount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveryRating: deliveryRating ?? this.deliveryRating,
      deliveryComment: deliveryComment ?? this.deliveryComment,
    );
  }
}
