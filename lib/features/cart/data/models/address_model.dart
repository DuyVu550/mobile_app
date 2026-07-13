import '../entities/address.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.id,
    required super.receiverName,
    required super.phoneNumber,
    required super.addressLine,
    required super.isDefault,
  });

  factory AddressModel.fromFirestore(String id, Map<String, dynamic> data) {
    return AddressModel(
      id: id,
      receiverName: (data['receiverName'] ?? '') as String,
      phoneNumber: (data['phoneNumber'] ?? '') as String,
      addressLine: (data['addressLine'] ?? '') as String,
      isDefault: (data['isDefault'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'receiverName': receiverName,
      'phoneNumber': phoneNumber,
      'addressLine': addressLine,
      'isDefault': isDefault,
    };
  }
}
