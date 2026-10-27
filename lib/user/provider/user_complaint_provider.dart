import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../admin/model/complaint_model.dart';

class UserComplaintProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  List<ComplaintModel> myComplaints = [];

  Future<bool> submitComplaint({
    required String subject,
    required String description,
    String? ownerId,
    String? bookingId,
    String? vehicleId,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        errorMessage = 'User not authenticated';
        return false;
      }

      final trimmedSubject = subject.trim();
      final trimmedDesc = description.trim();

      if (trimmedSubject.isEmpty || trimmedDesc.isEmpty) {
        errorMessage = 'Subject and description cannot be empty';
        return false;
      }

      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await _firestore.collection('complaints').add({
        'userId': user.uid,
        'ownerId': ownerId ?? '',
        'bookingId': bookingId ?? '',
        'vehicleId': vehicleId ?? '',
        'subject': trimmedSubject,
        'description': trimmedDesc,
        'submittedBy': 'user',
        'status': 'pending',
        'adminReply': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      isSubmitting = false;
      notifyListeners();

      // Refresh list
      await getMyComplaints();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> getMyComplaints() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('complaints')
          .where('userId', isEqualTo: user.uid)
          .get();

      myComplaints = snapshot.docs.map((doc) {
        return ComplaintModel.fromMap(doc.data(), doc.id);
      }).toList();

      // Sort in memory by createdAt descending
      myComplaints.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        if (a.createdAt is Timestamp && b.createdAt is Timestamp) {
          return (b.createdAt as Timestamp).compareTo(a.createdAt as Timestamp);
        }
        return b.id.compareTo(a.id);
      });

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}
