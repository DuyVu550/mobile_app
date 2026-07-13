import 'package:toy_app/features/cart/domain/entities/address.dart';

abstract interface class AddressRepository {
  Stream<List<Address>> watchAddresses(String userId);
  Future<void> addAddress(String userId, Address address);
  Future<void> setDefaultAddress(String userId, String addressId);
}
