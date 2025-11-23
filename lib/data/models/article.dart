import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final String title;
  final String? subtitle;
  final String content;
  final String? coverImageUrl;
  final String authorId;
  final String authorName;
  final String? authorPhotoUrl;
  final List<String> tags;
  final String? category;
  final String status; // "draft" | "published"
  final int readTimeMinutes;
  final int likesCount;
  final int commentsCount;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Timestamp? publishedAt;

  Article({
    required this.id,
    required this.title,
    this.subtitle,
    required this.content,
    this.coverImageUrl,
    required this.authorId,
    required this.authorName,
    this.authorPhotoUrl,
    required this.tags,
    this.category,
    required this.status,
    required this.readTimeMinutes,
    required this.likesCount,
    required this.commentsCount,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'coverImageUrl': coverImageUrl,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'tags': tags,
      'category': category,
      'status': status,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'publishedAt': publishedAt,
      'readTimeMinutes': readTimeMinutes,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
    };
  }
}
