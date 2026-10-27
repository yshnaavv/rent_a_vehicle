import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/admin_owner_model.dart';

class AdminOwnerProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AdminOwnerModel> owners = [];
  bool isLoading = false;
  String? errorMessage;

  List<AdminOwnerModel> get pendingOwners =>
      owners.where((o) => o.approvalStatus.toLowerCase() == 'pending').toList();

  List<AdminOwnerModel> get approvedOwners => owners
      .where((o) => o.approvalStatus.toLowerCase() == 'approved')
      .toList();

  List<AdminOwnerModel> get suspendedOrRejectedOwners => owners.where((o) {
    final s = o.approvalStatus.toLowerCase();
    return s == 'rejected' || s == 'suspended';
  }).toList();

  Future<void> getOwners() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore.collection('owners').get();

      owners = snapshot.docs.map((doc) {
        return AdminOwnerModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updatePartnerStatus({
    required String ownerId,
    required String status,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _firestore.collection('owners').doc(ownerId).update({
        'approvalStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await getOwners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> approvePartner(String ownerId) =>
      updatePartnerStatus(ownerId: ownerId, status: 'approved');

  Future<bool> rejectPartner(String ownerId) =>
      updatePartnerStatus(ownerId: ownerId, status: 'rejected');

  Future<bool> suspendPartner(String ownerId) =>
      updatePartnerStatus(ownerId: ownerId, status: 'suspended');

  Future<bool> reactivatePartner(String ownerId) =>
      updatePartnerStatus(ownerId: ownerId, status: 'approved');
}
