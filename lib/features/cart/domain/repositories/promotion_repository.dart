import 'package:toy_app/features/cart/domain/entities/promotion.dart';

abstract interface class PromotionRepository {
  Stream<List<Promotion>> watchActivePromotions();
}
