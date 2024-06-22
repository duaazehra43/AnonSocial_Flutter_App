import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/userModel.dart'; // Assuming UserModel is defined for users

class ChatViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _users = [];

  User? get currentUser => _auth.currentUser;

  void getUsers() {
    _firestore.collection('users').snapshots().listen((snapshot) {
      _users =
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  UserModel getUser(int index) {
    return _users[index];
  }

  int get usersCount => _users.length;

  String? get currentUserId => currentUser?.uid;

  String getAnonymousName() {
    return _auth.currentUser!.uid;
  }

  void signOut() async {
    await _auth.signOut();
  }
}
