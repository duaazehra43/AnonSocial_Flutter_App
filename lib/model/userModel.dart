import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String anonymousName;

  UserModel({
    required this.id,
    required this.anonymousName,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      anonymousName:
          data['anonymousName'] ?? '', // Adjust as per your Firestore structure
    );
  }
}
