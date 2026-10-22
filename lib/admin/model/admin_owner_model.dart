class AdminOwnerModel {
  final String uid;
  final String fullName;
  final String email;
  final String mobile;
  final String shopName;
  final String city;
  final String state;
  final String pincode;
  final String role;

  AdminOwnerModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.shopName,
    required this.city,
    required this.state,
    required this.pincode,
    required this.role,
  });

  factory AdminOwnerModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return AdminOwnerModel(
      uid: documentId,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      shopName: map['shopName'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      role: map['role'] ?? 'owner',
    );
  }
}