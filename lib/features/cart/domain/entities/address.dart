class Address {
  final String id;
  final String receiverName;
  final String phoneNumber;
  final String addressLine;
  final bool isDefault;

  const Address({
    required this.id,
    required this.receiverName,
    required this.phoneNumber,
    required this.addressLine,
    required this.isDefault,
  });
}
