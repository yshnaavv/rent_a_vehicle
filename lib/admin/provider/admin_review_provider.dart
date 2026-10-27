import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/review_model.dart';

class AdminReviewProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ReviewModel>> getReviews() async {
    QuerySnapshot snapshot = await _firestore
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<bool> approveReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'isApproved': true,
      });

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).update({
        'isApproved': false,
      });

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
