class ComplaintModel {
  final String id;
  final String userId;
  final String ownerId;
  final String bookingId;
  final String vehicleId;
  final String subject;
  final String description;
  final String submittedBy;
  final String status;
  final String adminReply;
  final dynamic createdAt;

  ComplaintModel({
    required this.id,
    required this.userId,
    required this.ownerId,
    required this.bookingId,
    required this.vehicleId,
    required this.subject,
    required this.description,
    required this.submittedBy,
    required this.status,
    required this.adminReply,
    this.createdAt,
  });

  factory ComplaintModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ComplaintModel(
      id: documentId,
      userId: map['userId'] ?? '',
      ownerId: map['ownerId'] ?? '',
      bookingId: map['bookingId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      subject: map['subject'] ?? '',
      description: map['description'] ?? '',
      submittedBy: map['submittedBy'] ?? '',
      status: map['status'] ?? 'pending',
      adminReply: map['adminReply'] ?? '',
      createdAt: map['createdAt'],
    );
  }
}
