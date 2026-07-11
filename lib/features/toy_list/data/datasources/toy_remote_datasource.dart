import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/toy_model.dart';
import '../models/brand_model.dart';

/// Nguồn dữ liệu sản phẩm đồ chơi realtime từ Firestore.
///
/// Collection `toys`, mỗi document là 1 sản phẩm. Trả stream để UI
/// tự cập nhật khi dữ liệu trên Firebase thay đổi.
class ToyRemoteDataSource {
  final FirebaseFirestore _firestore;

  ToyRemoteDataSource(this._firestore);

  static const _collection = 'toys';
  static const _brandsCollection = 'brands';

  /// Stream danh sách sản phẩm, sắp xếp theo tên cho ổn định.
  Stream<List<ToyModel>> watchToys() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ToyModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Lấy chi tiết 1 sản phẩm theo id (null nếu không tồn tại).
  Future<ToyModel?> fetchToyById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return ToyModel.fromFirestore(doc.id, doc.data()!);
  }

  /// Stream danh sách thương hiệu đồ chơi realtime từ Firestore.
  Stream<List<BrandModel>> watchBrands() {
    return _firestore
        .collection(_brandsCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BrandModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }
}

