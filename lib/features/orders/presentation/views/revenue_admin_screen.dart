import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toy_app/core/utils/string_utils.dart';
import 'package:toy_app/features/orders/presentation/controllers/order_providers.dart';
import 'package:toy_app/features/orders/domain/entities/order_entity.dart';
import 'admin_shared_widgets.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

class _RevenueSummary {
  final double totalRevenue;
  final int orderCount;
  final double averageOrderValue;
  final Map<DateTime, double> revenueByDay;

  const _RevenueSummary({
    required this.totalRevenue,
    required this.orderCount,
    required this.averageOrderValue,
    required this.revenueByDay,
  });
}

_RevenueSummary _computeSummary(List<OrderEntity> orders) {
  if (orders.isEmpty) {
    return const _RevenueSummary(
      totalRevenue: 0,
      orderCount: 0,
      averageOrderValue: 0,
      revenueByDay: {},
    );
  }

  double total = 0;
  final Map<DateTime, double> byDay = {};

  for (final o in orders) {
    total += o.totalPrice;
    final day = DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
    byDay[day] = (byDay[day] ?? 0) + o.totalPrice;
  }

  return _RevenueSummary(
    totalRevenue: total,
    orderCount: orders.length,
    averageOrderValue: total / orders.length,
    revenueByDay: byDay,
  );
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class RevenueAdminScreen extends ConsumerStatefulWidget {
  const RevenueAdminScreen({super.key});

  @override
  ConsumerState<RevenueAdminScreen> createState() => _RevenueAdminScreenState();
}

class _RevenueAdminScreenState extends ConsumerState<RevenueAdminScreen> {
  late DateTime _start;
  late DateTime _end;

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
          'DOANH THU BÁN HÀNG',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
          final filtered = allOrders.where((o) {
            final day = DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
            final startDay = DateTime(_start.year, _start.month, _start.day);
            final endDay = DateTime(_end.year, _end.month, _end.day);
            return !day.isBefore(startDay) && !day.isAfter(endDay);
          }).toList();

          final summary = _computeSummary(filtered);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminDateRangeButton(start: _start, end: _end, onTap: _pickDateRange),
                const SizedBox(height: 16),
                _KpiRow(summary: summary),
                const SizedBox(height: 20),
                if (summary.revenueByDay.isNotEmpty) ...[
                  Text(
                    'Doanh thu theo ngày',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _BarChartCard(summary: summary, start: _start, end: _end),
                ] else
                  AdminEmptyState(
                    start: _start,
                    end: _end,
                    icon: Icons.bar_chart_rounded,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── KPI Row ─────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  final _RevenueSummary summary;
  const _KpiRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            icon: Icons.attach_money_rounded,
            iconColor: Colors.green.shade600,
            label: 'Tổng doanh thu',
            value: formatPrice(summary.totalRevenue),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            icon: Icons.receipt_long_outlined,
            iconColor: Colors.blue.shade600,
            label: 'Số đơn',
            value: '${summary.orderCount}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            icon: Icons.trending_up_rounded,
            iconColor: Colors.orange.shade600,
            label: 'TB/đơn',
            value: summary.orderCount > 0 ? formatPrice(summary.averageOrderValue) : '—',
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// ─── Bar Chart ────────────────────────────────────────────────────────────────

class _BarChartCard extends StatelessWidget {
  final _RevenueSummary summary;
  final DateTime start;
  final DateTime end;

  const _BarChartCard({required this.summary, required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    final days = <DateTime>[];
    var cur = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    while (!cur.isAfter(endDay)) {
      days.add(cur);
      cur = cur.add(const Duration(days: 1));
    }

    final displayDays = days.length > 31 ? days.sublist(days.length - 31) : days;

    final maxY = summary.revenueByDay.values.fold<double>(0, (a, b) => a > b ? a : b);
    final chartMax = maxY == 0 ? 1.0 : maxY * 1.2;

    final bars = displayDays.asMap().entries.map((entry) {
      final revenue = summary.revenueByDay[entry.value] ?? 0.0;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: revenue,
            color: revenue > 0 ? Colors.blueGrey.shade700 : Colors.grey.shade200,
            width: displayDays.length <= 7 ? 18 : (displayDays.length <= 14 ? 12 : 7),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: chartMax,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: chartMax / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 56,
                      interval: chartMax / 4,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          _shortPrice(value),
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: displayDays.length <= 7
                          ? 1
                          : (displayDays.length <= 14 ? 2 : 5).toDouble(),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= displayDays.length) {
                          return const SizedBox.shrink();
                        }
                        final d = displayDays[idx];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${d.day}/${d.month}',
                            style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: bars,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.blueGrey.shade800,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = displayDays[group.x];
                      return BarTooltipItem(
                        '${day.day}/${day.month}\n${formatPrice(rod.toY)}',
                        const TextStyle(
                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          if (days.length > 31)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '* Chỉ hiển thị 31 ngày gần nhất trong khoảng đã chọn',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade600,
                    fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  String _shortPrice(double value) {
    if (value >= 1000000000) return '${(value / 1000000000).toStringAsFixed(1)}tỷ';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(0)}tr';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    return value.toStringAsFixed(0);
  }
}
