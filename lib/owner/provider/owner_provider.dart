import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OwnerProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? ownerData;

  String get currentApprovalStatus {
    return (ownerData?['approvalStatus'] ?? 'pending').toString().toLowerCase();
  }

  bool get isApproved => currentApprovalStatus == 'approved';

  Future<bool> registerOwner({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    required String shopName,
    required String shopAddress,
    required String city,
    required String state,
    required String pincode,
    required String shopPhone,
    required double latitude,
    required double longitude,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = credential.user!.uid;

      final data = {
        'uid': uid,
        'fullName': fullName.trim(),
        'email': email.trim(),
        'mobile': mobile.trim(),
        'shopName': shopName.trim(),
        'shopAddress': shopAddress.trim(),
        'city': city.trim(),
        'state': state.trim(),
        'pincode': pincode.trim(),
        'shopPhone': shopPhone.trim(),
        'latitude': latitude,
        'longitude': longitude,
        'role': 'owner',
        'approvalStatus': 'pending', // Partner starts in pending approval
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('owners').doc(uid).set(data);

      await loadOwnerData();

      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> loginOwner({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = credential.user!.uid;

      DocumentSnapshot document = await _firestore
          .collection('owners')
          .doc(uid)
          .get();

      if (!document.exists) {
        errorMessage = 'Partner account details not found in database.';
        await _auth.signOut();
        isLoading = false;
        notifyListeners();
        return null;
      }

      ownerData = document.data() as Map<String, dynamic>;
      final status = (ownerData?['approvalStatus'] ?? 'pending')
          .toString()
          .toLowerCase();

      isLoading = false;
      notifyListeners();
      return status;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadOwnerData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot document = await _firestore
        .collection('owners')
        .doc(user.uid)
        .get();

    if (document.exists) {
      ownerData = document.data() as Map<String, dynamic>;
      notifyListeners();
    }
  }

  Future<String> checkApprovalStatus() async {
    User? user = _auth.currentUser;
    if (user == null) return 'pending';

    DocumentSnapshot document = await _firestore
        .collection('owners')
        .doc(user.uid)
        .get();

    if (document.exists) {
      ownerData = document.data() as Map<String, dynamic>;
      notifyListeners();
      return currentApprovalStatus;
    }
    return 'pending';
  }

  Future<bool> updateOwnerProfile({
    required String fullName,
    required String mobile,
    required String shopName,
    required String shopAddress,
    required String city,
    required String state,
    required String pincode,
    required String shopPhone,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('owners').doc(user.uid).update({
        'fullName': fullName.trim(),
        'mobile': mobile.trim(),
        'shopName': shopName.trim(),
        'shopAddress': shopAddress.trim(),
        'city': city.trim(),
        'state': state.trim(),
        'pincode': pincode.trim(),
        'shopPhone': shopPhone.trim(),
      });

      await loadOwnerData();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    ownerData = null;
    notifyListeners();
  }
}
