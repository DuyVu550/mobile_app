import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

/// Nguồn dữ liệu sản phẩm realtime từ Firestore collection `/products`.
abstract interface class ProductRemoteDataSource {
  Stream<List<ProductModel>> watchProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProductRemoteDataSourceImpl(this._firestore);

  static const _collection = 'products';

  @override
  Stream<List<ProductModel>> watchProducts() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromFirestore(doc.id, doc.data()))
            .toList());
  }
}
