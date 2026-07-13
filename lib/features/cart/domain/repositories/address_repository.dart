import '../../data/models/address_model.dart';

abstract interface class AddressRepository {
  Stream<List<AddressModel>> watchAddresses(String userId);
  Future<void> addAddress(String userId, AddressModel address);
  Future<void> setDefaultAddress(String userId, String addressId);
}
