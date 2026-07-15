class Promotion {
  final String id;
  final String code;
  final String description;
  final double discountPercent;
  final double minOrderValue;
  final bool isActive;
  final DateTime? endDate;

  const Promotion({
    required this.id,
    required this.code,
    required this.description,
    required this.discountPercent,
    required this.minOrderValue,
    required this.isActive,
    this.endDate,
  });

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }
}
