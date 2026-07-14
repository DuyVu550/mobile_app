import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/features/auth/domain/entities/app_user.dart';
import 'package:toy_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:toy_app/features/orders/domain/entities/order_entity.dart';
import 'package:toy_app/features/orders/domain/repositories/order_repository.dart';
import 'package:toy_app/features/orders/presentation/controllers/order_providers.dart';

class FakeOrderRepository implements OrderRepository {
  final List<OrderEntity> orders;
  bool submitReviewCalled = false;
  String? lastReviewOrderId;
  int? lastReviewRating;
  String? lastReviewComment;

  FakeOrderRepository(this.orders);

  @override
  Stream<List<OrderEntity>> watchUserOrders(String userId) => Stream.value(
        orders.where((o) => o.userId == userId).toList(),
      );

  @override
  Stream<List<OrderEntity>> watchAllOrders() => Stream.value(orders);

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {}

  @override
  Future<void> submitOrder(OrderEntity order) async {}

  @override
  Future<void> submitDeliveryReview(String orderId, int rating, String comment) async {
    submitReviewCalled = true;
    lastReviewOrderId = orderId;
    lastReviewRating = rating;
    lastReviewComment = comment;
  }
}

void main() {
  final testOrders = [
    OrderEntity(
      id: 'o1',
      userId: 'user1',
      receiverName: 'John',
      phoneNumber: '123',
      addressLine: '123 St',
      paymentMethod: 'COD',
      items: [],
      totalPrice: 100.0,
      discount: 0.0,
      status: 'Đang chuẩn bị',
      createdAt: DateTime.now(),
    ),
    OrderEntity(
      id: 'o2',
      userId: 'user1',
      receiverName: 'John',
      phoneNumber: '123',
      addressLine: '123 St',
      paymentMethod: 'COD',
      items: [],
      totalPrice: 200.0,
      discount: 0.0,
      status: 'Đã hoàn thành',
      createdAt: DateTime.now(),
    ),
  ];

  test('userOrdersProvider filters active vs completed in memory', () async {
    final container = ProviderContainer(
      overrides: [
        orderRepositoryProvider.overrideWithValue(FakeOrderRepository(testOrders)),
        authStateProvider.overrideWith((ref) => Stream.value(
              const AppUser(uid: 'user1', email: 'user@test.com', displayName: 'User'),
            )),
      ],
    );
    addTearDown(container.dispose);

    final authUser = await container.read(authStateProvider.future);
    expect(authUser, isNotNull);

    // Start reading the futures (attaches listeners to the stream)
    final activeOrdersFuture = container.read(userOrdersProvider('Đang xử lý').future);
    final completedOrdersFuture = container.read(userOrdersProvider('Đã hoàn thành').future);

    final activeOrders = await activeOrdersFuture;
    expect(activeOrders.length, 1);
    expect(activeOrders[0].id, 'o1');
    expect(activeOrders[0].status, 'Đang chuẩn bị');

    // Wait for the provider to resolve completed orders
    final completedOrders = await completedOrdersFuture;
    expect(completedOrders.length, 1);
    expect(completedOrders[0].id, 'o2');
    expect(completedOrders[0].status, 'Đã hoàn thành');
  });

  test('adminOrdersProvider filters active vs completed in memory', () async {
    final container = ProviderContainer(
      overrides: [
        orderRepositoryProvider.overrideWithValue(FakeOrderRepository(testOrders)),
      ],
    );
    addTearDown(container.dispose);

    // Wait for active
    final activeOrders = await container.read(adminOrdersProvider('Đang xử lý').future);
    expect(activeOrders.length, 1);
    expect(activeOrders[0].id, 'o1');

    // Wait for completed
    final completedOrders = await container.read(adminOrdersProvider('Đã hoàn thành').future);
    expect(completedOrders.length, 1);
    expect(completedOrders[0].id, 'o2');
  });

  test('OrderController.submitReview calls repository with correct arguments', () async {
    final repository = FakeOrderRepository([]);
    final container = ProviderContainer(
      overrides: [
        orderRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final success = await container
        .read(orderControllerProvider.notifier)
        .submitReview('o2', 5, 'Good delivery');

    expect(success, true);
    expect(repository.submitReviewCalled, true);
    expect(repository.lastReviewOrderId, 'o2');
    expect(repository.lastReviewRating, 5);
    expect(repository.lastReviewComment, 'Good delivery');
  });
}
