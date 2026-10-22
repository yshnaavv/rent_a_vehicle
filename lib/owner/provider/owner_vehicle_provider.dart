import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/vehicle_model.dart';

class OwnerVehicleProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  bool isLoading = false;

  String? errorMessage;

  List<OwnerVehicleModel> vehicles = [];

  Future<bool> addVehicle({
    required String vehicleName,
    required String brand,
    required String model,
    required String category,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required double pricePerDay,
    required String transmission,
    required String fuelType,
    required int seats,
    required List<String> images,
    required String shopName,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        errorMessage = 'Owner not logged in';
        return false;
      }

      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _firestore.collection('vehicles').add({
        'ownerId': user.uid,

        'vehicleName': vehicleName.trim(),
        'brand': brand.trim(),
        'model': model.trim(),
        'category': category,

        'description': description.trim(),
        'location': location.trim(),

        'latitude': latitude,
        'longitude': longitude,

        'pricePerDay': pricePerDay,

        'transmission': transmission,
        'fuelType': fuelType,

        'seats': seats,

        'images': images,

        'shopName': shopName,

        // Important
        'approvalStatus': 'pending',

        'isAvailable': true,

        'createdAt':
            FieldValue.serverTimestamp(),
      });

      isLoading = false;
      notifyListeners();

      await getMyVehicles();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();

      return false;
    }
  }

  Future<void> getMyVehicles() async {
    try {
      User? user = _auth.currentUser;

      if (user == null) return;

      isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot =
          await _firestore
              .collection('vehicles')
              .where(
                'ownerId',
                isEqualTo: user.uid,
              )
              .get();

      vehicles = snapshot.docs.map((document) {
        return OwnerVehicleModel.fromMap(
          document.data()
              as Map<String, dynamic>,
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

  Future<bool> updateVehicle({
    required String vehicleId,
    required String vehicleName,
    required String brand,
    required String model,
    required String category,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required double pricePerDay,
    required String transmission,
    required String fuelType,
    required int seats,
    required List<String> images,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _firestore
          .collection('vehicles')
          .doc(vehicleId)
          .update({
        'vehicleName': vehicleName.trim(),
        'brand': brand.trim(),
        'model': model.trim(),
        'category': category,
        'description': description.trim(),
        'location': location.trim(),
        'latitude': latitude,
        'longitude': longitude,
        'pricePerDay': pricePerDay,
        'transmission': transmission,
        'fuelType': fuelType,
        'seats': seats,
        'images': images,

        // Edit requires admin approval again
        'approvalStatus': 'pending',
      });

      isLoading = false;
      notifyListeners();

      await getMyVehicles();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();

      return false;
    }
  }

  Future<bool> changeAvailability(
    String vehicleId,
    bool value,
  ) async {
    try {
      await _firestore
          .collection('vehicles')
          .doc(vehicleId)
          .update({
        'isAvailable': value,
      });

      await getMyVehicles();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteVehicle(
    String vehicleId,
  ) async {
    try {
      await _firestore
          .collection('vehicles')
          .doc(vehicleId)
          .delete();

      await getMyVehicles();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }
}