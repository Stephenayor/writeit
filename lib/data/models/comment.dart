import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final int repliesCount;
  final String avatarUrl;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    required this.likesCount,
    required this.repliesCount,
    required this.avatarUrl,
  });

  factory Comment.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    return Comment(
      id: doc.id,
      userId: d['userId'] ?? '',
      userName: d['userName'] ?? 'Unknown',
      text: d['text'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: d['likesCount'] ?? 0,
      repliesCount: d['repliesCount'] ?? 0,
      avatarUrl: d['avatarUrl'] ?? '',
    );
  }
}
