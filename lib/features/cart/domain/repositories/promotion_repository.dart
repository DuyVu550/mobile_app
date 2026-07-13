import '../../data/models/promotion_model.dart';

abstract interface class PromotionRepository {
  Stream<List<PromotionModel>> watchActivePromotions();
}
