class AdminBookingModel {
  final String id;
  final String userId;
  final String ownerId;
  final String vehicleId;
  final String vehicleName;
  final String shopName;
  final String startDate;
  final String endDate;
  final int numberOfDays;
  final double totalAmount;
  final String status;

  AdminBookingModel({
    required this.id,
    required this.userId,
    required this.ownerId,
    required this.vehicleId,
    required this.vehicleName,
    required this.shopName,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
    required this.totalAmount,
    required this.status,
  });

  factory AdminBookingModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return AdminBookingModel(
      id: documentId,
      userId: map['userId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      vehicleName: map['vehicleName'] ?? '',
      shopName: map['shopName'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      numberOfDays:
          map['numberOfDays'] ?? 0,
      totalAmount:
          (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
    );
  }
}