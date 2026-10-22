import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/admin_owner_model.dart';

class AdminOwnerProvider
    extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  List<AdminOwnerModel> owners = [];

  Future<void> getOwners() async {
    QuerySnapshot snapshot =
        await _firestore
            .collection('owners')
            .get();

    owners = snapshot.docs.map((doc) {
      return AdminOwnerModel.fromMap(
        doc.data()
            as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    notifyListeners();
  }
}