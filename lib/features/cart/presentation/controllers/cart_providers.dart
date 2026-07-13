import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/core/providers/firebase_providers.dart';
import 'package:toy_app/features/auth/presentation/controllers/auth_providers.dart';
import 'package:toy_app/features/products/presentation/controllers/product_list_notifier.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/models/cart_item_model.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return CartRepositoryImpl(CartRemoteDataSourceImpl(firestore));
});

final cartStreamProvider = StreamProvider<List<CartItemModel>>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  if (auth == null) return Stream.value([]);
  return ref.watch(cartRepositoryProvider).watchCart(auth.uid);
});

final cartItemsProvider = Provider<AsyncValue<List<CartItem>>>((ref) {
  final cartModelsAsync = ref.watch(cartStreamProvider);
  final productsState = ref.watch(productListNotifierProvider);

  return cartModelsAsync.when(
    data: (models) {
      return productsState.products.when(
        data: (products) {
          try {
            final items = models.map((model) {
              final product = products.firstWhere(
                (p) => p.id == model.productId,
                orElse: () => throw Exception('Không tìm thấy sản phẩm có ID ${model.productId}'),
              );
              return CartItem(
                productId: model.productId,
                product: product,
                quantity: model.quantity,
              );
            }).toList();
            return AsyncValue.data(items);
          } catch (e, stack) {
            return AsyncValue.error(e, stack);
          }
        },
        loading: () => const AsyncValue.loading(),
        error: (err, stack) => AsyncValue.error(err, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

final cartTotalPriceProvider = Provider<double>((ref) {
  final itemsAsync = ref.watch(cartItemsProvider).valueOrNull ?? [];
  return itemsAsync.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
});

final cartItemCountProvider = Provider<int>((ref) {
  final itemsAsync = ref.watch(cartStreamProvider).valueOrNull ?? [];
  return itemsAsync.fold(0, (sum, item) => sum + item.quantity);
});

class CartActionNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> add(String productId, int quantity) async {
    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(cartRepositoryProvider).addToCart(auth.uid, productId, quantity));
  }

  Future<void> updateQty(String productId, int quantity) async {
    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(cartRepositoryProvider).updateQuantity(auth.uid, productId, quantity));
  }

  Future<void> remove(String productId) async {
    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(cartRepositoryProvider).removeFromCart(auth.uid, productId));
  }
}

final cartActionControllerProvider =
    AutoDisposeAsyncNotifierProvider<CartActionNotifier, void>(() => CartActionNotifier());
