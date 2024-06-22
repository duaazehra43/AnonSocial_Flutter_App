import 'package:anonymous_app/model/postModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  String? anonymousName;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      user = user;
      notifyListeners();
    });
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      this.user = null;
      anonymousName = null;
    } else {
      this.user = user;
      await _loadAnonymousName();
    }
    notifyListeners();
  }

  Future<void> _loadAnonymousName() async {
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user!.uid).get();
      if (doc.exists) {
        anonymousName = doc.data()!['anonymousName'];
      } else {
        anonymousName = _generateRandomName();
        await _firestore
            .collection('users')
            .doc(user!.uid)
            .set({'anonymousName': anonymousName});
      }
    }
  }

  String _generateRandomName() {
    const adjectives = ['Brave', 'Clever', 'Happy', 'Sad', 'Angry'];
    const nouns = ['Lion', 'Tiger', 'Bear', 'Shark', 'Eagle'];
    final random = Random();
    return '${adjectives[random.nextInt(adjectives.length)]} ${nouns[random.nextInt(nouns.length)]}';
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    final UserCredential userCredential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);
    user = userCredential.user;
    anonymousName = _generateRandomName();
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .set({'anonymousName': anonymousName});
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    final UserCredential userCredential = await _auth
        .signInWithEmailAndPassword(email: email, password: password);
    user = userCredential.user;
    await _loadAnonymousName();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  bool get isAuthenticated => user != null;

  Future<void> savePost(String content) async {
    try {
      String anonymousName =
          await getAnonymousName(); // Get user's anonymous name
      await _firestore.collection('posts').add({
        'userId': user!.uid,
        'anonymousName': anonymousName,
        'content': content,
        'timestamp': Timestamp.now(),
        'likes': 0,
        'repostedBy': null,
        'originalAnonymousName': null,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      DocumentReference postRef = _firestore.collection('posts').doc(postId);
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(postRef);
        if (!snapshot.exists) {
          throw Exception("Post does not exist!");
        }

        int newLikes = snapshot['likes'] + 1;
        transaction.update(postRef, {'likes': newLikes});
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> repostPost(Post post) async {
    try {
      String anonymousName = await getAnonymousName();
      await _firestore.collection('posts').add({
        'userId': user!.uid,
        'anonymousName': anonymousName,
        'content': post.content,
        'timestamp': Timestamp.now(),
        'likes': 0,
        'repostedBy': anonymousName,
        'originalAnonymousName': post.anonymousName,
      });
    } catch (e) {
      throw e;
    }
  }

  Stream<List<Post>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) =>
            snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  Future<String> getAnonymousName() async {
    String userId = _auth.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await _firestore.collection('users').doc(userId).get();
    return userDoc['anonymousName'];
  }

  User? get currentUser => _auth.currentUser;
}
