class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String ownerId;
  final String vehicleId;
  final String vehicleName;
  final double rating;
  final String comment;
  final bool isApproved;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.ownerId,
    required this.vehicleId,
    required this.vehicleName,
    required this.rating,
    required this.comment,
    required this.isApproved,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ReviewModel(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      ownerId: map['ownerId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      vehicleName: map['vehicleName'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      isApproved: map['isApproved'] ?? false,
    );
  }
}
