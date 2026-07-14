import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/core/utils/string_utils.dart';
import 'package:toy_app/features/orders/presentation/controllers/order_providers.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch sử mua hàng'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
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
            OrderListTab(status: 'Đang xử lý'),
            OrderListTab(status: 'Đã hoàn thành'),
          ],
        ),
      ),
    );
  }
}

class OrderListTab extends ConsumerWidget {
  final String status;

  const OrderListTab({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrdersProvider(status));

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
                  'Mã ĐH: ...${order.id.substring(order.id.length > 5 ? order.id.length - 5 : 0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        if (order.status != 'Đã hoàn thành') ...[
                          const Text(
                            'Theo dõi đơn hàng:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStep(context, 'Nhận đơn', true),
                              _buildStep(
                                context,
                                'Chuẩn bị',
                                order.status == 'Đang chuẩn bị' || order.status == 'Đang giao',
                              ),
                              _buildStep(
                                context,
                                'Đang giao',
                                order.status == 'Đang giao',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                        ] else ...[
                          const Divider(),
                        ],
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
                        if (order.status == 'Đã hoàn thành') ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          if (order.deliveryRating != null) ...[
                            Row(
                              children: [
                                const Text(
                                  'Đánh giá giao hàng: ',
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
                              Text('Nhận xét: ${order.deliveryComment}'),
                            ],
                          ] else ...[
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showRatingDialog(context, ref, order.id),
                                icon: const Icon(Icons.rate_review_outlined),
                                label: const Text('Đánh giá giao hàng'),
                              ),
                            ),
                          ],
                        ],
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

  void _showRatingDialog(BuildContext context, WidgetRef ref, String orderId) {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Đánh giá dịch vụ giao hàng'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chọn số sao hài lòng:'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        icon: Icon(
                          starValue <= selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = starValue;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Nhận xét (không bắt buộc)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () async {
                    final success = await ref
                        .read(orderControllerProvider.notifier)
                        .submitReview(orderId, selectedRating, commentController.text.trim());
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? 'Cảm ơn bạn đã đánh giá!'
                              : 'Gửi đánh giá thất bại.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Gửi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStep(BuildContext context, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isActive ? Colors.green : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.green : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
