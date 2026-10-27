import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OwnerBookingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;

  List<Map<String, dynamic>> bookings = [];

  Future<void> getOwnerBookings() async {
    try {
      User? user = _auth.currentUser;

      if (user == null) return;

      isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      bookings = snapshot.docs.map((document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        data['id'] = document.id;

        return data;
      }).toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
      });

      await getOwnerBookings();

      return true;
    } catch (e) {
      return false;
    }
  }
}
