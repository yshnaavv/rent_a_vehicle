import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/vehicle_model.dart';

class VehicleProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  List<VehicleModel> vehicles = [];

  bool isLoading = false;

  String? errorMessage;

  // ================= GET ALL VEHICLES =================

  Future<void> getVehicles() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('vehicles')
          .where(
            'approvalStatus',
            isEqualTo: 'approved',
          )
          .where(
            'isAvailable',
            isEqualTo: true,
          )
          .get();

      vehicles = snapshot.docs.map((document) {
        return VehicleModel.fromMap(
          document.data() as Map<String, dynamic>,
          document.id,
        );
      }).toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();
    }
  }

  // ================= GET BY CATEGORY =================

  Future<List<VehicleModel>> getVehiclesByCategory(
    String category,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('vehicles')
          .where(
            'category',
            isEqualTo: category,
          )
          .where(
            'approvalStatus',
            isEqualTo: 'approved',
          )
          .where(
            'isAvailable',
            isEqualTo: true,
          )
          .get();

      return snapshot.docs.map((document) {
        return VehicleModel.fromMap(
          document.data() as Map<String, dynamic>,
          document.id,
        );
      }).toList();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return [];
    }
  }

  // ================= GET SINGLE VEHICLE =================

  Future<VehicleModel?> getVehicle(
    String vehicleId,
  ) async {
    try {
      DocumentSnapshot document =
          await _firestore
              .collection('vehicles')
              .doc(vehicleId)
              .get();

      if (!document.exists) {
        return null;
      }

      return VehicleModel.fromMap(
        document.data() as Map<String, dynamic>,
        document.id,
      );
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return null;
    }
  }
}