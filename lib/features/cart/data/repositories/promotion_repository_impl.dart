import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../../data/models/promotion_model.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final FirebaseFirestore _firestore;

  PromotionRepositoryImpl(this._firestore);

  @override
  Stream<List<PromotionModel>> watchActivePromotions() {
    return _firestore
        .collection('promotions')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PromotionModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }
}
