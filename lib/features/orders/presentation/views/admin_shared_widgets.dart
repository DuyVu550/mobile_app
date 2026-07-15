import 'package:flutter/material.dart';

/// Shared helper — format DateTime thành dd/MM/yyyy
String fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Date range picker button dùng chung cho các màn hình admin chart
class AdminDateRangeButton extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final VoidCallback onTap;

  const AdminDateRangeButton({
    super.key,
    required this.start,
    required this.end,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueGrey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range_outlined, color: Colors.blueGrey.shade600, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${fmtDate(start)}  →  ${fmtDate(end)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade800,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueGrey.shade400),
          ],
        ),
      ),
    );
  }
}

/// Empty state dùng chung — icon tuỳ chỉnh
class AdminEmptyState extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final IconData icon;

  const AdminEmptyState({
    super.key,
    required this.start,
    required this.end,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Không có đơn hoàn thành\ntrong khoảng ${fmtDate(start)} – ${fmtDate(end)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
