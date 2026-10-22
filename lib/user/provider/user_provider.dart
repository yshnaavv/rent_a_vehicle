import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool isLoading = false;

  String? errorMessage;

  Map<String, dynamic>? userData;

  // ================= REGISTER =================

  Future<bool> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await loadUserData();

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

  // ================= LOGIN =================

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      String uid = userCredential.user!.uid;

      DocumentSnapshot document =
          await _firestore.collection('users').doc(uid).get();

      if (!document.exists) {
        errorMessage = 'User data not found';

        isLoading = false;
        notifyListeners();

        return null;
      }

      Map<String, dynamic> data =
          document.data() as Map<String, dynamic>;

      String role = data['role'] ?? 'user';

      await loadUserData();

      isLoading = false;
      notifyListeners();

      return role;
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

  // ================= LOAD USER =================

  Future<void> loadUserData() async {
    User? user = _auth.currentUser;

    if (user == null) {
      return;
    }

    DocumentSnapshot document =
        await _firestore.collection('users').doc(user.uid).get();

    if (document.exists) {
      userData =
          document.data() as Map<String, dynamic>;

      notifyListeners();
    }
  }

  // ================= UPDATE PROFILE =================

  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return false;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'name': name.trim(),
        'phone': phone.trim(),
      });

      await loadUserData();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();

      return false;
    }
  }

  // ================= LOGOUT =================

  Future<void> logout() async {
    await _auth.signOut();

    userData = null;

    notifyListeners();
  }
}