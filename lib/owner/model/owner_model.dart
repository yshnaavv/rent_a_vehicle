class OwnerModel {
  final String uid;
  final String fullName;
  final String email;
  final String mobile;

  final String shopName;
  final String shopAddress;
  final String city;
  final String state;
  final String pincode;
  final String shopPhone;

  final double latitude;
  final double longitude;

  final String role;

  OwnerModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.shopName,
    required this.shopAddress,
    required this.city,
    required this.state,
    required this.pincode,
    required this.shopPhone,
    required this.latitude,
    required this.longitude,
    required this.role,
  });

  factory OwnerModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return OwnerModel(
      uid: documentId,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      shopName: map['shopName'] ?? '',
      shopAddress: map['shopAddress'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      shopPhone: map['shopPhone'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      role: map['role'] ?? 'owner',
    );
  }
}