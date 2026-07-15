import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toy_app/features/cart/domain/entities/promotion.dart';

class PromotionModel extends Promotion {
  const PromotionModel({
    required String id,
    required String code,
    required String description,
    required double discountPercent,
    required double minOrderValue,
    required bool isActive,
    DateTime? endDate,
  }) : super(
          id: id,
          code: code,
          description: description,
          discountPercent: discountPercent,
          minOrderValue: minOrderValue,
          isActive: isActive,
          endDate: endDate,
        );

  factory PromotionModel.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime? parsedEndDate;
    final rawEnd = data['endDate'];
    if (rawEnd is Timestamp) {
      parsedEndDate = rawEnd.toDate();
    } else if (rawEnd is String) {
      parsedEndDate = DateTime.tryParse(rawEnd);
    }
    return PromotionModel(
      id: id,
      code: (data['code'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      discountPercent: ((data['discountPercent'] ?? 0.0) as num).toDouble(),
      minOrderValue: ((data['minOrderValue'] ?? 0.0) as num).toDouble(),
      isActive: (data['isActive'] ?? false) as bool,
      endDate: parsedEndDate,
    );
  }
}
