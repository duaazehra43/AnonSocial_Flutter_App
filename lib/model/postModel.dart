import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String anonymousName;
  final String content;
  final DateTime timestamp;
  final int likes;
  final String? repostedBy;
  final String? originalAnonymousName;

  Post({
    required this.id,
    required this.userId,
    required this.anonymousName,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.repostedBy,
    this.originalAnonymousName,
  });

  factory Post.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return Post(
      id: doc.id,
      userId: data['userId'],
      anonymousName: data['anonymousName'],
      content: data['content'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
      repostedBy: data['repostedBy'],
      originalAnonymousName: data['originalAnonymousName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'anonymousName': anonymousName,
      'content': content,
      'timestamp': timestamp,
      'likes': likes,
      'repostedBy': repostedBy,
      'originalAnonymousName': originalAnonymousName,
    };
  }
}
