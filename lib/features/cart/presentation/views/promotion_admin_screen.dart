import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toy_app/core/providers/firebase_providers.dart';
import 'package:toy_app/core/utils/string_utils.dart';
import 'package:toy_app/features/cart/data/models/promotion_model.dart';
import 'package:toy_app/features/cart/domain/entities/promotion.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

final adminPromotionsProvider =
    StreamProvider<List<Promotion>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('promotions')
      .orderBy('code')
      .snapshots()
      .map((s) => s.docs
          .map<Promotion>((d) => PromotionModel.fromFirestore(d.id, d.data()))
          .toList());
});

// ─── Screen ──────────────────────────────────────────────────────────────────

class PromotionAdminScreen extends ConsumerStatefulWidget {
  const PromotionAdminScreen({super.key});

  @override
  ConsumerState<PromotionAdminScreen> createState() =>
      _PromotionAdminScreenState();
}

class _PromotionAdminScreenState
    extends ConsumerState<PromotionAdminScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Add / Edit dialog ──────────────────────────────────────────────────────

  Future<void> _showAddEditDialog([String? id, Promotion? promo]) async {
    final codeCtrl =
        TextEditingController(text: promo?.code ?? '');
    final descCtrl =
        TextEditingController(text: promo?.description ?? '');
    final discountCtrl = TextEditingController(
        text: promo != null ? promo.discountPercent.toStringAsFixed(0) : '');
    final minOrderCtrl = TextEditingController(
        text: promo != null ? promo.minOrderValue.toStringAsFixed(0) : '');
    bool isActive = promo?.isActive ?? true;
    DateTime? endDate = promo?.endDate;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModal) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            id == null ? 'Thêm khuyến mãi' : 'Chỉnh sửa khuyến mãi',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 360,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Code
                    TextFormField(
                      controller: codeCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _inputDeco('Mã khuyến mãi (VD: SUMMER20)'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                    ),
                    const SizedBox(height: 12),
                    // Description
                    TextFormField(
                      controller: descCtrl,
                      decoration: _inputDeco('Mô tả'),
                      maxLines: 2,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                    ),
                    const SizedBox(height: 12),
                    // Discount
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: discountCtrl,
                          keyboardType: TextInputType.number,
                          decoration:
                              _inputDeco('Giảm giá (%)'),
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n <= 0 || n > 100) {
                              return '1–100';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: minOrderCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDeco('Đơn tối thiểu (đ)'),
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n < 0) return 'Không hợp lệ';
                            return null;
                          },
                        ),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    // isActive toggle
                    Row(
                      children: [
                        Switch(
                          value: isActive,
                          activeThumbColor: Colors.green.shade600,
                          onChanged: (v) => setModal(() => isActive = v),
                        ),
                        Text(
                          isActive ? 'Đang hoạt động' : 'Tạm dừng',
                          style: TextStyle(
                            color: isActive
                                ? Colors.green.shade700
                                : Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Expiration Date Time Picker
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            endDate == null
                                ? 'Không giới hạn thời gian'
                                : 'Hết hạn: ${endDate!.day}/${endDate!.month}/${endDate!.year} ${endDate!.hour.toString().padLeft(2, '0')}:${endDate!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 13,
                              color: endDate == null ? Colors.grey.shade600 : Colors.blueGrey.shade900,
                              fontWeight: endDate == null ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (date != null) {
                              if (context.mounted) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(endDate ?? DateTime.now()),
                                );
                                if (time != null) {
                                  setModal(() {
                                    endDate = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      time.hour,
                                      time.minute,
                                    );
                                  });
                                }
                              }
                            }
                          },
                          child: const Text('Chọn'),
                        ),
                        if (endDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setModal(() => endDate = null),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Hủy',
                  style: TextStyle(color: Colors.grey.shade600)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade900),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final payload = {
                  'code': codeCtrl.text.trim().toUpperCase(),
                  'description': descCtrl.text.trim(),
                  'discountPercent':
                      double.parse(discountCtrl.text.trim()),
                  'minOrderValue':
                      double.parse(minOrderCtrl.text.trim()),
                  'isActive': isActive,
                  'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
                };

                final col =
                    ref.read(firestoreProvider).collection('promotions');
                if (id == null) {
                  await col.add(payload);
                } else {
                  await col.doc(id).update(payload);
                }

                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> _deletePromotion(String id, String code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Xác nhận xóa'),
        content:
            Text('Bạn có chắc muốn xóa khuyến mãi "$code"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Hủy',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(firestoreProvider)
          .collection('promotions')
          .doc(id)
          .delete();
    }
  }

  // ── Toggle active ──────────────────────────────────────────────────────────

  Future<void> _toggleActive(String id, bool current) async {
    await ref
        .read(firestoreProvider)
        .collection('promotions')
        .doc(id)
        .update({'isActive': !current});
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final promotionsAsync = ref.watch(adminPromotionsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'QUẢN LÝ KHUYẾN MÃI',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey.shade800,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo mã hoặc mô tả...',
                prefixIcon: Icon(Icons.search,
                    color: Colors.blueGrey.shade400, size: 22),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 0, horizontal: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Colors.blueGrey.shade600, width: 1.5),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        }),
                      )
                    : null,
              ),
              onChanged: (v) =>
                  setState(() => _searchQuery = v.trim().toLowerCase()),
            ),
          ),

          // List
          Expanded(
            child: promotionsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text('Lỗi: $err')),
              data: (promotions) {
                final q = _searchQuery;
                final filtered = promotions.where((p) {
                  return p.code.toLowerCase().contains(q) ||
                      p.description.toLowerCase().contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Không tìm thấy khuyến mãi nào.',
                      style:
                          TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final p = filtered[idx];
                    return _PromotionCard(
                      promo: p,
                      onEdit: () => _showAddEditDialog(p.id, p),
                      onDelete: () => _deletePromotion(p.id, p.code),
                      onToggle: () => _toggleActive(p.id, p.isActive),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        hoverElevation: 2,
        label: const Text('Thêm khuyến mãi'),
        icon: const Icon(Icons.add),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

InputDecoration _inputDeco(String label) => InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );

// ─── Promotion Card ───────────────────────────────────────────────────────────

class _PromotionCard extends StatelessWidget {
  final Promotion promo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _PromotionCard({
    required this.promo,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = promo.isActive;
    final isExpired = promo.isExpired;
    final showActive = isActive && !isExpired;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: showActive
              ? Colors.green.shade200
              : (isActive && isExpired ? Colors.red.shade200 : Colors.grey.shade200),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge + icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: showActive
                    ? Colors.green.shade50
                    : (isActive && isExpired ? Colors.red.shade50 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.local_offer_outlined,
                color: showActive
                    ? Colors.green.shade600
                    : (isActive && isExpired ? Colors.red.shade600 : Colors.grey.shade400),
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        promo.code,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(isActive: isActive, isExpired: isExpired),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promo.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.percent,
                        label:
                            'Giảm ${promo.discountPercent.toStringAsFixed(0)}%',
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.shopping_bag_outlined,
                        label:
                            'Tối thiểu ${formatPrice(promo.minOrderValue)}',
                        color: Colors.blue.shade700,
                      ),
                    ],
                  ),
                  if (promo.endDate != null) ...[
                    const SizedBox(height: 6),
                    _InfoChip(
                      icon: Icons.access_time,
                      label:
                          'Hết hạn: ${promo.endDate!.day}/${promo.endDate!.month}/${promo.endDate!.year} ${promo.endDate!.hour.toString().padLeft(2, '0')}:${promo.endDate!.minute.toString().padLeft(2, '0')}',
                      color: isExpired ? Colors.red.shade700 : Colors.blueGrey.shade700,
                    ),
                  ],
                ],
              ),
            ),
            // Actions column
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      color: Colors.blue.shade600, size: 20),
                  tooltip: 'Chỉnh sửa',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(
                    isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    color: isActive
                        ? Colors.orange.shade600
                        : Colors.green.shade600,
                    size: 20,
                  ),
                  tooltip:
                      isActive ? 'Tạm dừng' : 'Kích hoạt',
                  onPressed: onToggle,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Colors.red.shade600, size: 20),
                  tooltip: 'Xóa',
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final bool isExpired;
  const _StatusBadge({required this.isActive, this.isExpired = false});

  @override
  Widget build(BuildContext context) {
    final showExpired = isActive && isExpired;
    final color = showExpired
        ? Colors.red
        : (isActive ? Colors.green : Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.shade300,
        ),
      ),
      child: Text(
        showExpired
            ? 'Hết hạn'
            : (isActive ? 'Đang hoạt động' : 'Tạm dừng'),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.shade700,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

