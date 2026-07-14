import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:toy_app/features/orders/data/repositories/order_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late OrderRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = OrderRepositoryImpl(firestore);
  });

  test('watchUserOrders returns user orders sorted by createdAt descending', () async {
    await firestore.collection('orders').add({
      'userId': 'user1',
      'status': 'Đang xử lý',
      'createdAt': DateTime(2026, 7, 10),
      'receiverName': 'John',
      'phoneNumber': '123',
      'addressLine': '123 St',
      'paymentMethod': 'COD',
      'items': [],
      'totalPrice': 100.0,
      'discount': 0.0,
    });

    await firestore.collection('orders').add({
      'userId': 'user1',
      'status': 'Đang chuẩn bị',
      'createdAt': DateTime(2026, 7, 12),
      'receiverName': 'John',
      'phoneNumber': '123',
      'addressLine': '123 St',
      'paymentMethod': 'COD',
      'items': [],
      'totalPrice': 150.0,
      'discount': 0.0,
    });

    final list = await repository.watchUserOrders('user1').first;
    expect(list.length, 2);
    expect(list[0].totalPrice, 150.0); // Newest first
  });

  test('watchAllOrders returns all orders sorted by createdAt descending', () async {
    await firestore.collection('orders').add({
      'userId': 'user1',
      'status': 'Đang xử lý',
      'createdAt': DateTime(2026, 7, 10),
      'receiverName': 'John',
      'phoneNumber': '123',
      'addressLine': '123 St',
      'paymentMethod': 'COD',
      'items': [],
      'totalPrice': 100.0,
      'discount': 0.0,
    });

    await firestore.collection('orders').add({
      'userId': 'user2',
      'status': 'Đang chuẩn bị',
      'createdAt': DateTime(2026, 7, 12),
      'receiverName': 'Alice',
      'phoneNumber': '456',
      'addressLine': '456 St',
      'paymentMethod': 'COD',
      'items': [],
      'totalPrice': 200.0,
      'discount': 0.0,
    });

    final list = await repository.watchAllOrders().first;
    expect(list.length, 2);
    expect(list[0].totalPrice, 200.0); // Newest first
  });

  test('submitDeliveryReview updates deliveryRating and deliveryComment', () async {
    final docRef = await firestore.collection('orders').add({
      'userId': 'user1',
      'status': 'Đã hoàn thành',
      'createdAt': DateTime.now(),
      'receiverName': 'John',
      'phoneNumber': '123',
      'addressLine': '123 St',
      'paymentMethod': 'COD',
      'items': [],
      'totalPrice': 100.0,
      'discount': 0.0,
    });

    await repository.submitDeliveryReview(docRef.id, 5, 'Giao nhanh, nhiệt tình');

    final docSnapshot = await firestore.collection('orders').doc(docRef.id).get();
    expect(docSnapshot.data()?['deliveryRating'], 5);
    expect(docSnapshot.data()?['deliveryComment'], 'Giao nhanh, nhiệt tình');
  });
}
