import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toy_app/features/cart/domain/entities/promotion.dart';
import 'package:toy_app/features/cart/domain/repositories/promotion_repository.dart';
import 'package:toy_app/features/cart/data/models/promotion_model.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final FirebaseFirestore _firestore;

  PromotionRepositoryImpl(this._firestore);

  @override
  Stream<List<Promotion>> watchActivePromotions() {
    return _firestore
        .collection('promotions')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map<Promotion>((doc) => PromotionModel.fromFirestore(doc.id, doc.data()))
            .where((p) => !p.isExpired)
            .toList());
  }
}
