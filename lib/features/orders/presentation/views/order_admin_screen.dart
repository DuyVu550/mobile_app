import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/core/utils/string_utils.dart';
import 'package:toy_app/features/orders/presentation/controllers/order_providers.dart';

class OrderAdminScreen extends StatelessWidget {
  const OrderAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý Đơn hàng'),
          backgroundColor: Colors.blueGrey[800],
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(text: 'Đang xử lý'),
              Tab(text: 'Đã hoàn thành'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminOrderListTab(status: 'Đang xử lý'),
            AdminOrderListTab(status: 'Đã hoàn thành'),
          ],
        ),
      ),
    );
  }
}

class AdminOrderListTab extends ConsumerWidget {
  final String status;

  const AdminOrderListTab({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider(status));
    final controllerState = ref.watch(orderControllerProvider);

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
            child: Text(
              'Không có đơn hàng nào ở trạng thái này.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ExpansionTile(
                title: Text(
                  'Đơn hàng: ...${order.id.substring(order.id.length > 5 ? order.id.length - 5 : 0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Đặt bởi User ID: ${order.userId}'),
                    Text('Ngày đặt: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}'),
                    Text(
                      'Tổng tiền: ${formatPrice(order.totalPrice)}',
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text('Người nhận: ${order.receiverName} - ${order.phoneNumber}'),
                        Text('Địa chỉ: ${order.addressLine}'),
                        Text('Thanh toán: ${order.paymentMethod == 'COD' ? 'Thanh toán khi nhận hàng (COD)' : 'Chuyển khoản ngân hàng'}'),
                        if (order.discount > 0) Text('Giảm giá: ${order.discount}%'),
                        const SizedBox(height: 8),
                        const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text('${item.productName} x${item.quantity}')),
                              Text(formatPrice(item.price * item.quantity)),
                            ],
                          ),
                        )),
                        if (order.deliveryRating != null) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          Row(
                            children: [
                              const Text(
                                'Khách hàng đánh giá giao hàng: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < order.deliveryRating!
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                            ],
                          ),
                          if (order.deliveryComment != null && order.deliveryComment!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('Ý kiến khách hàng: ${order.deliveryComment}'),
                          ],
                        ],
                        if (order.status != 'Đã hoàn thành')
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: controllerState.isLoading
                                  ? null
                                  : () async {
                                      String newStatus = '';
                                      String actionText = '';
                                      if (order.status == 'Đang xử lý') {
                                        newStatus = 'Đang chuẩn bị';
                                        actionText = 'Bắt đầu chuẩn bị đơn hàng này?';
                                      } else if (order.status == 'Đang chuẩn bị') {
                                        newStatus = 'Đang giao';
                                        actionText = 'Giao đơn hàng này cho khách?';
                                      } else if (order.status == 'Đang giao') {
                                        newStatus = 'Đã hoàn thành';
                                        actionText = 'Đánh dấu đơn hàng này là đã hoàn thành?';
                                      }

                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Xác nhận'),
                                          content: Text(actionText),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(false),
                                              child: const Text('Hủy'),
                                            ),
                                            FilledButton(
                                              onPressed: () => Navigator.of(ctx).pop(true),
                                              child: const Text('Đồng ý'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        final success = await ref
                                            .read(orderControllerProvider.notifier)
                                            .updateStatus(order.id, newStatus);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(success
                                                  ? 'Cập nhật trạng thái thành công!'
                                                  : 'Lỗi khi cập nhật đơn hàng.'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: order.status == 'Đang xử lý'
                                    ? Colors.orange
                                    : (order.status == 'Đang chuẩn bị' ? Colors.blue : Colors.green),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: Icon(order.status == 'Đang xử lý'
                                  ? Icons.cookie_outlined
                                  : (order.status == 'Đang chuẩn bị' ? Icons.local_shipping_outlined : Icons.check_circle_outline)),
                              label: Text(order.status == 'Đang xử lý'
                                  ? 'Bắt đầu chuẩn bị'
                                  : (order.status == 'Đang chuẩn bị' ? 'Giao hàng cho khách' : 'Hoàn thành đơn hàng')),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Lỗi tải dữ liệu: $err')),
    );
  }
}
