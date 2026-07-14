import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/core/providers/firebase_providers.dart';
import 'package:toy_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:toy_app/features/orders/domain/entities/order_entity.dart';
import 'package:toy_app/features/orders/domain/repositories/order_repository.dart';
import 'package:toy_app/features/orders/data/repositories/order_repository_impl.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return OrderRepositoryImpl(firestore);
});

final userOrdersProvider = StreamProvider.family<List<OrderEntity>, String>((ref, status) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  if (auth == null) return Stream.value([]);
  return ref.watch(orderRepositoryProvider).watchUserOrders(auth.uid).map((orders) {
    if (status == 'Đã hoàn thành') {
      return orders.where((o) => o.status == 'Đã hoàn thành').toList();
    } else {
      return orders.where((o) => o.status != 'Đã hoàn thành').toList();
    }
  });
});

final adminOrdersProvider = StreamProvider.family<List<OrderEntity>, String>((ref, status) {
  return ref.watch(orderRepositoryProvider).watchAllOrders().map((orders) {
    if (status == 'Đã hoàn thành') {
      return orders.where((o) => o.status == 'Đã hoàn thành').toList();
    } else {
      return orders.where((o) => o.status != 'Đã hoàn thành').toList();
    }
  });
});

class OrderController extends StateNotifier<AsyncValue<void>> {
  final OrderRepository _repository;

  OrderController(this._repository) : super(const AsyncValue.data(null));

  Future<bool> updateStatus(String orderId, String newStatus) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateOrderStatus(orderId, newStatus);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> submitReview(String orderId, int rating, String comment) async {
    state = const AsyncValue.loading();
    try {
      await _repository.submitDeliveryReview(orderId, rating, comment);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

final orderControllerProvider = StateNotifierProvider<OrderController, AsyncValue<void>>((ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return OrderController(repo);
});
