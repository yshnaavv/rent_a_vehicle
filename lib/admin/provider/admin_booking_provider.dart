import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/admin_booking_model.dart';

class AdminBookingProvider
    extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  List<AdminBookingModel> bookings = [];

  Future<void> getBookings() async {
    QuerySnapshot snapshot =
        await _firestore
            .collection('bookings')
            .get();

    bookings = snapshot.docs.map((doc) {
      return AdminBookingModel.fromMap(
        doc.data()
            as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    notifyListeners();
  }
}