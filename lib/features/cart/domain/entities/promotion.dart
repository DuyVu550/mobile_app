class Promotion {
  final String id;
  final String code;
  final String description;
  final double discountPercent;
  final double minOrderValue;
  final bool isActive;

  const Promotion({
    required this.id,
    required this.code,
    required this.description,
    required this.discountPercent,
    required this.minOrderValue,
    required this.isActive,
  });
}
