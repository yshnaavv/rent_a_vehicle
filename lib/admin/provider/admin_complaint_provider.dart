import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/complaint_model.dart';

class AdminComplaintProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<List<ComplaintModel>> getComplaints() async {
    final snapshot = await _firestore
        .collection('complaints')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .get();

    return snapshot.docs.map((doc) {
      return ComplaintModel.fromMap(
        doc.data(),
        doc.id,
      );
    }).toList();
  }

  Future<bool> updateComplaintStatus({
    required String complaintId,
    required String status,
  }) async {
    try {
      await _firestore
          .collection('complaints')
          .doc(complaintId)
          .update({
        'status': status,
      });

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> replyToComplaint({
    required String complaintId,
    required String reply,
  }) async {
    try {
      await _firestore
          .collection('complaints')
          .doc(complaintId)
          .update({
        'adminReply': reply,
        'status': 'in_progress',
      });

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteComplaint(
    String complaintId,
  ) async {
    try {
      await _firestore
          .collection('complaints')
          .doc(complaintId)
          .delete();

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}