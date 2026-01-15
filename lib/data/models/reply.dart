import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final String id;
  final String userId;
  final String userName;
  final String? avatarUrl;
  final String text;
  final DateTime createdAt;

  Reply({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    this.avatarUrl,
  });

  factory Reply.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    return Reply(
      id: doc.id,
      userId: d['userId'] ?? '',
      userName: d['userName'] ?? 'Unknown',
      avatarUrl: d['avatarUrl'],
      text: d['text'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
