class AdminVehicleModel {
  final String id;
  final String ownerId;
  final String vehicleName;
  final String brand;
  final String model;
  final String category;
  final String location;
  final double pricePerDay;
  final String shopName;
  final String approvalStatus;
  final bool isAvailable;
  final List<String> images;

  AdminVehicleModel({
    required this.id,
    required this.ownerId,
    required this.vehicleName,
    required this.brand,
    required this.model,
    required this.category,
    required this.location,
    required this.pricePerDay,
    required this.shopName,
    required this.approvalStatus,
    required this.isAvailable,
    this.images = const [],
  });

  factory AdminVehicleModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return AdminVehicleModel(
      id: documentId,
      ownerId: map['ownerId'] ?? '',
      vehicleName: map['vehicleName'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      pricePerDay: (map['pricePerDay'] ?? 0).toDouble(),
      shopName: map['shopName'] ?? '',
      approvalStatus: map['approvalStatus'] ?? 'pending',
      isAvailable: map['isAvailable'] ?? false,
      images: List<String>.from(map['images'] ?? []),
    );
  }
}