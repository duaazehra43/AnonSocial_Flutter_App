import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/authService.dart';
import '../model/postModel.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService authService;

  ProfileViewModel({required this.authService});

  Stream<List<Post>> getUserPostsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  Future<String> getAnonymousName() async {
    return await authService.getAnonymousName();
  }
}
