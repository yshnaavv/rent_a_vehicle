import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  bool isLoading = false;

  String? errorMessage;

  List<BookingModel> bookings = [];

  // ================= CREATE BOOKING =================

  Future<bool> createBooking({
    required String ownerId,
    required String vehicleId,
    required String vehicleName,
    required String shopName,
    required String location,
    required String startDate,
    required String endDate,
    required int numberOfDays,
    required double totalAmount,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        errorMessage = 'User not logged in';
        return false;
      }

      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _firestore.collection('bookings').add({
        'userId': user.uid,
        'ownerId': ownerId,
        'vehicleId': vehicleId,
        'vehicleName': vehicleName,
        'shopName': shopName,
        'location': location,
        'startDate': startDate,
        'endDate': endDate,
        'numberOfDays': numberOfDays,
        'totalAmount': totalAmount,

        // No real payment in our project.
        'paymentStatus': 'not_required',

        'status': 'pending',

        'createdAt': FieldValue.serverTimestamp(),
      });

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();

      return false;
    }
  }

  // ================= GET MY BOOKINGS =================

  Future<void> getMyBookings() async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return;
      }

      isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where(
            'userId',
            isEqualTo: user.uid,
          )
          .get();

      bookings = snapshot.docs.map((document) {
        return BookingModel.fromMap(
          document.data() as Map<String, dynamic>,
          document.id,
        );
      }).toList();

      bookings.sort(
        (a, b) => b.id.compareTo(a.id),
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();

      isLoading = false;
      notifyListeners();
    }
  }

  // ================= CANCEL BOOKING =================

  Future<bool> cancelBooking(
    String bookingId,
  ) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': 'cancelled',
      });

      await getMyBookings();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }
}