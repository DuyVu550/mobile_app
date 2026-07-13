import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toy_app/features/cart/domain/entities/address.dart';
import 'package:toy_app/features/cart/domain/repositories/address_repository.dart';
import 'package:toy_app/features/cart/data/models/address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final FirebaseFirestore _firestore;

  AddressRepositoryImpl(this._firestore);

  CollectionReference _addressCol(String userId) =>
      _firestore.collection('users/$userId/addresses');

  @override
  Stream<List<Address>> watchAddresses(String userId) {
    return _addressCol(userId).snapshots().map((snapshot) => snapshot.docs
        .map<Address>((doc) => AddressModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }

  @override
  Future<void> addAddress(String userId, Address address) async {
    final docRef = _addressCol(userId).doc();
    final model = AddressModel(
      id: address.id,
      receiverName: address.receiverName,
      phoneNumber: address.phoneNumber,
      addressLine: address.addressLine,
      isDefault: address.isDefault,
    );
    final data = model.toFirestore();
    if (address.isDefault) {
      final batch = _firestore.batch();
      final existing = await _addressCol(userId).get();
      for (final doc in existing.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      batch.set(docRef, data);
      await batch.commit();
    } else {
      await docRef.set(data);
    }
  }

  @override
  Future<void> setDefaultAddress(String userId, String addressId) async {
    final batch = _firestore.batch();
    final existing = await _addressCol(userId).get();
    for (final doc in existing.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == addressId});
    }
    await batch.commit();
  }
}
