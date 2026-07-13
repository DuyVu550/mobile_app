import '../entities/promotion.dart';

class PromotionModel extends Promotion {
  const PromotionModel({
    required super.id,
    required super.code,
    required super.description,
    required super.discountPercent,
    required super.minOrderValue,
    required super.isActive,
  });

  factory PromotionModel.fromFirestore(String id, Map<String, dynamic> data) {
    return PromotionModel(
      id: id,
      code: (data['code'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      discountPercent: ((data['discountPercent'] ?? 0.0) as num).toDouble(),
      minOrderValue: ((data['minOrderValue'] ?? 0.0) as num).toDouble(),
      isActive: (data['isActive'] ?? false) as bool,
    );
  }
}
