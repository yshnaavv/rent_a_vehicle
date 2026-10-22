import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/admin_vehicle_model.dart';

class AdminVehicleProvider extends ChangeNotifier {
  List<AdminVehicleModel> vehicles = [];
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;

  // Get all vehicles
  Future<List<AdminVehicleModel>> getVehicles() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('vehicles').get();

      return snapshot.docs.map((doc) {
        return AdminVehicleModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  // Get pending vehicles
  Future<List<AdminVehicleModel>> getPendingVehicles() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('vehicles')
            .where('approvalStatus', isEqualTo: 'pending')
            .get();

    return snapshot.docs.map((doc) {
      return AdminVehicleModel.fromMap(
        doc.data(),
        doc.id,
      );
    }).toList();
  }

  // Approve a vehicle
  Future<void> approveVehicle(String vehicleId) async {
  await _firestore.collection('vehicles').doc(vehicleId).update({
    'approvalStatus': 'approved',
    'isAvailable': true,
  });

  await getAllVehicles();
}

// reject vehicle
Future<void> rejectVehicle(String vehicleId) async {
  await _firestore.collection('vehicles').doc(vehicleId).update({
    'approvalStatus': 'rejected',
    'isAvailable': false,
  });

  await getAllVehicles();
}

  // Change vehicle availability
  Future<void> changeAvailability(
    String vehicleId,
    bool isAvailable,
  ) async {
    await _firestore.collection('vehicles').doc(vehicleId).update({
      'isAvailable': isAvailable,
    });

    notifyListeners();
  }

  // Delete a vehicle
  Future<void> deleteVehicle(String vehicleId) async {
    await _firestore.collection('vehicles').doc(vehicleId).delete();

    notifyListeners();
  }

  //get all vehicle
  Future<void> getAllVehicles() async {
  try {
    vehicles = await getVehicles();
    notifyListeners();
  } catch (e) {
    errorMessage = e.toString();
    notifyListeners();
  }
}
}