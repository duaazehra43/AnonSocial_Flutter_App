import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ChatDetailViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> sendMessage(String recipientId, String text) async {
    if (text.isNotEmpty) {
      await _firestore.collection('messages').add({
        'senderId': currentUser?.uid,
        'recipientId': recipientId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<QueryDocumentSnapshot>> getMessages(String recipientId) {
    var sentMessagesQuery = _firestore
        .collection('messages')
        .where('senderId', isEqualTo: currentUser?.uid)
        .where('recipientId', isEqualTo: recipientId)
        .snapshots();

    var receivedMessagesQuery = _firestore
        .collection('messages')
        .where('senderId', isEqualTo: recipientId)
        .where('recipientId', isEqualTo: currentUser?.uid)
        .snapshots();

    return Rx.combineLatest2(sentMessagesQuery, receivedMessagesQuery,
        (QuerySnapshot sent, QuerySnapshot received) {
      var allMessages = <QueryDocumentSnapshot>[];
      allMessages.addAll(sent.docs);
      allMessages.addAll(received.docs);
      allMessages.sort((a, b) {
        Timestamp aTimestamp = a['timestamp'] ?? Timestamp.now();
        Timestamp bTimestamp = b['timestamp'] ?? Timestamp.now();
        return aTimestamp.compareTo(bTimestamp);
      });
      return allMessages;
    });
  }

  String? get currentUserId => currentUser?.uid;

  Future<String> getAnonymousName() async {
    String userId = _auth.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await _firestore.collection('users').doc(userId).get();
    return userDoc['anonymousName'];
  }

  void signOut() async {
    await _auth.signOut();
  }
}
