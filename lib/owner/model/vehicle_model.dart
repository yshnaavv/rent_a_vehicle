class OwnerVehicleModel {
  final String id;
  final String ownerId;

  final String vehicleName;
  final String brand;
  final String model;
  final String category;

  final String description;
  final String location;
  final String city;

  final double latitude;
  final double longitude;

  final double pricePerDay;

  final String transmission;
  final String fuelType;

  final int seats;

  final List<String> images;

  final String approvalStatus;
  final bool isAvailable;

  final String shopName;

  OwnerVehicleModel({
    required this.id,
    required this.ownerId,
    required this.vehicleName,
    required this.brand,
    required this.model,
    required this.category,
    required this.description,
    required this.location,
    this.city = '',
    required this.latitude,
    required this.longitude,
    required this.pricePerDay,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.images,
    required this.approvalStatus,
    required this.isAvailable,
    required this.shopName,
  });

  factory OwnerVehicleModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return OwnerVehicleModel(
      id: documentId,
      ownerId: map['ownerId'] ?? '',
      vehicleName: map['vehicleName'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      city: map['city'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      pricePerDay: (map['pricePerDay'] ?? 0).toDouble(),
      transmission: map['transmission'] ?? '',
      fuelType: map['fuelType'] ?? '',
      seats: map['seats'] ?? 0,
      images: List<String>.from(map['images'] ?? []),
      approvalStatus: map['approvalStatus'] ?? 'pending',
      isAvailable: map['isAvailable'] ?? false,
      shopName: map['shopName'] ?? '',
    );
  }
}
