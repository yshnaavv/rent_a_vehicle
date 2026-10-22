class OfferModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double discountPercentage;
  final String vehicleId;
  final bool isActive;

  OfferModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.vehicleId,
    required this.isActive,
  });

  factory OfferModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return OfferModel(
      id: documentId,
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      discountPercentage:
          (map['discountPercentage'] ?? 0).toDouble(),
      vehicleId: map['vehicleId'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }
}