import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;

  Future<bool> loginAdmin({
    required String email,
    required String password,
  }) async {
    // Temporary admin login
    //
    // Later we can connect this to
    // Firebase Authentication.

    if (email == 'admin@gmail.com' && password == 'admin123') {
      return true;
    }

    errorMessage = 'Invalid admin login';
    notifyListeners();

    return false;
  }

  Future<int> getUserCount() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();

    return snapshot.docs.length;
  }

  Future<int> getOwnerCount() async {
    QuerySnapshot snapshot = await _firestore.collection('owners').get();

    return snapshot.docs.length;
  }

  Future<int> getVehicleCount() async {
    QuerySnapshot snapshot = await _firestore.collection('vehicles').get();

    return snapshot.docs.length;
  }

  Future<int> getBookingCount() async {
    QuerySnapshot snapshot = await _firestore.collection('bookings').get();

    return snapshot.docs.length;
  }
}
