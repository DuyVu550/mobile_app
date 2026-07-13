import 'package:toy_app/features/cart/domain/entities/promotion.dart';

class PromotionModel extends Promotion {
  const PromotionModel({
    required String id,
    required String code,
    required String description,
    required double discountPercent,
    required double minOrderValue,
    required bool isActive,
  }) : super(
          id: id,
          code: code,
          description: description,
          discountPercent: discountPercent,
          minOrderValue: minOrderValue,
          isActive: isActive,
        );

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
