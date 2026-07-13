import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/core/utils/string_utils.dart';
import 'package:toy_app/features/cart/presentation/controllers/cart_providers.dart';
import 'package:toy_app/features/cart/presentation/controllers/checkout_providers.dart';
import 'package:toy_app/features/cart/data/models/address_model.dart';
import 'package:toy_app/features/cart/domain/entities/address.dart';
import 'package:toy_app/features/cart/domain/entities/promotion.dart';
import 'package:toy_app/features/auth/presentation/controllers/auth_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _promoController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _addAddressDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final lineController = TextEditingController();
    bool isDefault = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm địa chỉ nhận hàng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên người nhận'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: lineController,
                  decoration: const InputDecoration(labelText: 'Địa chỉ chi tiết'),
                ),
                CheckboxListTile(
                  title: const Text('Đặt làm địa chỉ mặc định'),
                  value: isDefault,
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => isDefault = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    phoneController.text.isEmpty ||
                    lineController.text.isEmpty) return;

                try {
                  final repo = ref.read(addressRepositoryProvider);
                  final auth = ref.read(authStateProvider).valueOrNull;
                  if (auth != null) {
                    await repo.addAddress(
                      auth.uid,
                      AddressModel(
                        id: '',
                        receiverName: nameController.text,
                        phoneNumber: phoneController.text,
                        addressLine: lineController.text,
                        isDefault: isDefault,
                      ),
                    );
                  }
                  if (mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi khi lưu địa chỉ: $e')),
                    );
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _selectAddressBottomSheet(List<Address> addresses) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          children: [
            AppBar(
              title: const Text('Chọn địa chỉ nhận hàng'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _addAddressDialog();
                  },
                ),
              ],
            ),
            Expanded(
              child: addresses.isEmpty
                  ? const Center(child: Text('Chưa có địa chỉ nào được lưu.'))
                  : ListView.builder(
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final addr = addresses[index];
                        return ListTile(
                          title: Text('${addr.receiverName} - ${addr.phoneNumber}'),
                          subtitle: Text(addr.addressLine),
                          trailing: addr.isDefault ? const Icon(Icons.check, color: Colors.green) : null,
                          onTap: () {
                            ref.read(checkoutStateProvider.notifier).selectAddress(addr);
                            Navigator.of(ctx).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutStateProvider);
    final originalPrice = ref.watch(cartTotalPriceProvider);
    final addressesAsync = ref.watch(addressesProvider);
    final promotionsAsync = ref.watch(promotionsProvider);

    final addresses = addressesAsync.valueOrNull ?? [];
    final promotions = promotionsAsync.valueOrNull ?? [];

    // Filter promotions matching user input
    final typedCode = _promoController.text.trim().toUpperCase();
    final suggestedPromos = typedCode.isEmpty
        ? const <Promotion>[]
        : promotions
            .where((p) => p.code.toUpperCase().contains(typedCode))
            .toList();

    double discountAmount = 0.0;
    if (checkoutState.appliedPromotion != null &&
        originalPrice >= checkoutState.appliedPromotion!.minOrderValue) {
      discountAmount = originalPrice * (checkoutState.appliedPromotion!.discountPercent / 100);
    }
    final finalPrice = (originalPrice - discountAmount).clamp(0.0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.indigo),
                    const SizedBox(width: 12),
                    Expanded(
                      child: checkoutState.selectedAddress == null
                          ? const Text('Chưa có thông tin giao hàng')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${checkoutState.selectedAddress!.receiverName} (${checkoutState.selectedAddress!.phoneNumber})',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(checkoutState.selectedAddress!.addressLine),
                              ],
                            ),
                    ),
                    TextButton(
                      onPressed: () => _selectAddressBottomSheet(addresses),
                      child: const Text('Thay đổi'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Method Section
            const Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            RadioListTile<String>(
              title: const Text('Thanh toán khi nhận hàng (COD)'),
              value: 'COD',
              groupValue: checkoutState.paymentMethod,
              onChanged: (val) {
                if (val != null) {
                  ref.read(checkoutStateProvider.notifier).selectPaymentMethod(val);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Chuyển khoản ngân hàng'),
              value: 'Bank',
              groupValue: checkoutState.paymentMethod,
              onChanged: (val) {
                if (val != null) {
                  ref.read(checkoutStateProvider.notifier).selectPaymentMethod(val);
                }
              },
            ),
            const SizedBox(height: 16),

            // Promo Code Section
            const Text('Áp dụng mã khuyến mãi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập mã giảm giá...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final code = _promoController.text.trim().toUpperCase();
                    final match = promotions.where((p) => p.code.toUpperCase() == code).firstOrNull;
                    if (match != null) {
                      if (originalPrice >= match.minOrderValue) {
                        ref.read(checkoutStateProvider.notifier).applyPromotion(match);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Áp dụng mã giảm giá thành công!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đơn hàng chưa đạt giá trị tối thiểu ${formatPrice(match.minOrderValue)}')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mã giảm giá không hợp lệ.')),
                      );
                    }
                  },
                  child: const Text('Áp dụng'),
                ),
              ],
            ),
            if (suggestedPromos.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                constraints: const BoxConstraints(maxHeight: 120),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestedPromos.length,
                  itemBuilder: (context, index) {
                    final promo = suggestedPromos[index];
                    return ListTile(
                      title: Text(promo.code),
                      subtitle: Text(promo.description),
                      dense: true,
                      onTap: () {
                        setState(() {
                          _promoController.text = promo.code;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
            if (checkoutState.appliedPromotion != null) ...[
              const SizedBox(height: 8),
              Text(
                'Đã áp dụng mã: ${checkoutState.appliedPromotion!.code} (Giảm ${checkoutState.appliedPromotion!.discountPercent}%)',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
            const Divider(height: 32),

            // Order Summary
            const Text('Tổng kết đơn hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Giá tạm tính:'),
                Text(formatPrice(originalPrice)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Giảm giá:'),
                Text('-${formatPrice(discountAmount)}', style: const TextStyle(color: Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng thanh toán:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  formatPrice(finalPrice),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isPlacingOrder || checkoutState.selectedAddress == null
                    ? null
                    : () async {
                        setState(() => _isPlacingOrder = true);
                        try {
                          await ref.read(checkoutStateProvider.notifier).submitOrder(finalPrice);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đặt hàng thành công!')),
                            );
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đặt hàng thất bại: $e')),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isPlacingOrder = false);
                          }
                        }
                      },
                child: _isPlacingOrder
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Đặt hàng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
