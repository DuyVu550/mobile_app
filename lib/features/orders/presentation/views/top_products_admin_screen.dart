import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/core/utils/string_utils.dart';
import 'package:toy_app/features/orders/presentation/controllers/order_providers.dart';
import 'package:toy_app/features/orders/domain/entities/order_entity.dart';
import 'admin_shared_widgets.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

class _ProductStat {
  final String productId;
  final String productName;
  final int totalQuantity;
  final double totalRevenue;

  const _ProductStat({
    required this.productId,
    required this.productName,
    required this.totalQuantity,
    required this.totalRevenue,
  });
}

enum _RankMode { quantity, revenue }

// ─── Helper ───────────────────────────────────────────────────────────────────

List<_ProductStat> _computeTopProducts(
  List<OrderEntity> orders,
  DateTime start,
  DateTime end,
) {
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay = DateTime(end.year, end.month, end.day);

  final Map<String, _ProductStat> map = {};

  for (final order in orders) {
    final d = order.createdAt;
    final day = DateTime(d.year, d.month, d.day);
    if (day.isBefore(startDay) || day.isAfter(endDay)) continue;

    for (final item in order.items) {
      final existing = map[item.productId];
      if (existing == null) {
        map[item.productId] = _ProductStat(
          productId: item.productId,
          productName: item.productName,
          totalQuantity: item.quantity,
          totalRevenue: item.price * item.quantity,
        );
      } else {
        map[item.productId] = _ProductStat(
          productId: item.productId,
          productName: existing.productName,
          totalQuantity: existing.totalQuantity + item.quantity,
          totalRevenue: existing.totalRevenue + item.price * item.quantity,
        );
      }
    }
  }

  return map.values.toList();
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class TopProductsAdminScreen extends ConsumerStatefulWidget {
  const TopProductsAdminScreen({super.key});

  @override
  ConsumerState<TopProductsAdminScreen> createState() =>
      _TopProductsAdminScreenState();
}

class _TopProductsAdminScreenState
    extends ConsumerState<TopProductsAdminScreen> {
  late DateTime _start;
  late DateTime _end;
  _RankMode _mode = _RankMode.quantity;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, 1);
    _end = DateTime(now.year, now.month + 1, 0);
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _start, end: _end),
      locale: const Locale('vi'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.blueGrey.shade800,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _start = picked.start;
        _end = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allOrdersAsync = ref.watch(adminOrdersProvider('Đã hoàn thành'));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'SẢN PHẨM BÁN CHẠY NHẤT',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
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
      body: allOrdersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
        data: (allOrders) {
          final stats = _computeTopProducts(allOrders, _start, _end);

          stats.sort((a, b) => _mode == _RankMode.quantity
              ? b.totalQuantity.compareTo(a.totalQuantity)
              : b.totalRevenue.compareTo(a.totalRevenue));

          final top10 = stats.take(10).toList();

          // Tính maxVal 1 lần, không tính lại trong mỗi item builder
          final maxVal = top10.isEmpty
              ? 0.0
              : (_mode == _RankMode.quantity
                  ? top10.first.totalQuantity.toDouble()
                  : top10.first.totalRevenue);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    AdminDateRangeButton(
                        start: _start, end: _end, onTap: _pickDateRange),
                    const SizedBox(height: 10),
                    _ModeToggle(
                      mode: _mode,
                      onChanged: (m) => setState(() => _mode = m),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: top10.isEmpty
                    ? AdminEmptyState(
                        start: _start,
                        end: _end,
                        icon: Icons.leaderboard_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: top10.length,
                        itemBuilder: (context, idx) {
                          final stat = top10[idx];
                          final val = _mode == _RankMode.quantity
                              ? stat.totalQuantity.toDouble()
                              : stat.totalRevenue;
                          final ratio = maxVal > 0 ? val / maxVal : 0.0;

                          return _ProductRankCard(
                            rank: idx + 1,
                            stat: stat,
                            mode: _mode,
                            ratio: ratio,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Mode Toggle ─────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final _RankMode mode;
  final ValueChanged<_RankMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
              child: _ToggleChip(
            label: '📦 Số lượng',
            selected: mode == _RankMode.quantity,
            onTap: () => onChanged(_RankMode.quantity),
          )),
          Expanded(
              child: _ToggleChip(
            label: '💰 Doanh thu',
            selected: mode == _RankMode.revenue,
            onTap: () => onChanged(_RankMode.revenue),
          )),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 4,
                      offset: const Offset(0, 1))
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color:
                selected ? Colors.blueGrey.shade800 : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}

// ─── Product Rank Card ────────────────────────────────────────────────────────

class _ProductRankCard extends StatelessWidget {
  final int rank;
  final _ProductStat stat;
  final _RankMode mode;
  final double ratio;

  const _ProductRankCard({
    required this.rank,
    required this.stat,
    required this.mode,
    required this.ratio,
  });

  Widget _rankBadge() {
    if (rank <= 3) {
      const medals = ['🥇', '🥈', '🥉'];
      return Text(medals[rank - 1], style: const TextStyle(fontSize: 24));
    }
    return SizedBox(
      width: 32,
      child: Text(
        '#$rank',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Color _barColor() {
    if (rank == 1) return Colors.amber.shade600;
    if (rank == 2) return Colors.blueGrey.shade400;
    if (rank == 3) return Colors.brown.shade400;
    return Colors.blueGrey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final primaryVal = mode == _RankMode.quantity
        ? '${stat.totalQuantity} sp'
        : formatPrice(stat.totalRevenue);

    final secondaryVal = mode == _RankMode.quantity
        ? formatPrice(stat.totalRevenue)
        : '${stat.totalQuantity} sp';

    final secondaryLabel =
        mode == _RankMode.quantity ? 'Doanh thu' : 'Số lượng';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3 ? _barColor().withAlpha(80) : Colors.grey.shade200,
          width: rank <= 3 ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _rankBadge(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          primaryVal,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: rank == 1
                                ? Colors.amber.shade700
                                : Colors.blueGrey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$secondaryLabel: $secondaryVal',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor()),
            ),
          ),
        ],
      ),
    );
  }
}
