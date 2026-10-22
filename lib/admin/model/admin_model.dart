class AdminModel {
  final String uid;
  final String name;
  final String email;
  final String role;

  AdminModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AdminModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return AdminModel(
      uid: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'admin',
    );
  }
}