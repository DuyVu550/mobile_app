import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/core/providers/firebase_providers.dart';
import 'package:toy_app/features/auth/presentation/controllers/auth_providers.dart';
import '../../domain/repositories/address_repository.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../../data/repositories/promotion_repository_impl.dart';
import '../controllers/cart_providers.dart';
import '../../domain/entities/address.dart';
import '../../domain/entities/promotion.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return AddressRepositoryImpl(firestore);
});

final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return PromotionRepositoryImpl(firestore);
});

final addressesProvider = StreamProvider<List<Address>>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  if (auth == null) return Stream.value([]);
  return ref.watch(addressRepositoryProvider).watchAddresses(auth.uid);
});

final promotionsProvider = StreamProvider<List<Promotion>>((ref) {
  return ref.watch(promotionRepositoryProvider).watchActivePromotions();
});

class CheckoutState {
  final Address? selectedAddress;
  final String paymentMethod; // 'COD' or 'Bank'
  final Promotion? appliedPromotion;

  const CheckoutState({
    this.selectedAddress,
    this.paymentMethod = 'COD',
    this.appliedPromotion,
  });

  CheckoutState copyWith({
    Address? selectedAddress,
    String? paymentMethod,
    Promotion? Function()? appliedPromotion,
  }) {
    return CheckoutState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      appliedPromotion: appliedPromotion != null ? appliedPromotion() : this.appliedPromotion,
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref _ref;

  CheckoutNotifier(this._ref) : super(const CheckoutState()) {
    _initDefaultAddress();
  }

  void _initDefaultAddress() {
    _ref.listen<AsyncValue<List<Address>>>(addressesProvider, (prev, next) {
      final list = next.valueOrNull ?? [];
      if (list.isNotEmpty && state.selectedAddress == null) {
        final def = list.firstWhere((a) => a.isDefault, orElse: () => list.first);
        state = state.copyWith(selectedAddress: def);
      }
    });
  }

  void selectAddress(Address address) {
    state = state.copyWith(selectedAddress: address);
  }

  void selectPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void applyPromotion(Promotion? promo) {
    state = state.copyWith(appliedPromotion: () => promo);
  }

  Future<void> submitOrder(double finalPrice) async {
    final auth = _ref.read(authStateProvider).valueOrNull;
    if (auth == null || state.selectedAddress == null) return;

    final firestore = _ref.read(firestoreProvider);
    final cartItems = _ref.read(cartItemsProvider).valueOrNull ?? [];

    final orderRef = firestore.collection('orders').doc();
    final batch = firestore.batch();

    batch.set(orderRef, {
      'userId': auth.uid,
      'receiverName': state.selectedAddress!.receiverName,
      'phoneNumber': state.selectedAddress!.phoneNumber,
      'addressLine': state.selectedAddress!.addressLine,
      'paymentMethod': state.paymentMethod,
      'items': cartItems.map((item) => {
        'productId': item.productId,
        'productName': item.product.name,
        'quantity': item.quantity,
        'price': item.product.price,
      }).toList(),
      'totalPrice': finalPrice,
      'discount': state.appliedPromotion != null ? state.appliedPromotion!.discountPercent : 0.0,
      'status': 'Đang xử lý',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Clear Cart
    final cartSnapshot = await firestore.collection('users/${auth.uid}/cart').get();
    for (final doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}

final checkoutStateProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});
