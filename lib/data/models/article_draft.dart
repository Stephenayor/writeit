// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// class ArticleDraft {
//   final String id;
//   final String title;
//   final String content;
//   final List<String> imagePaths;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   ArticleDraft({
//     required this.id,
//     required this.title,
//     required this.content,
//     required this.imagePaths,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'title': title,
//     'content': content,
//     'imagePaths': imagePaths,
//     'createdAt': createdAt.toIso8601String(),
//     'updatedAt': updatedAt.toIso8601String(),
//   };
//
//   factory ArticleDraft.fromJson(Map<String, dynamic> json) => ArticleDraft(
//     id: json['id'],
//     title: json['title'],
//     content: json['content'],
//     imagePaths: List<String>.from(json['imagePaths'] ?? []),
//     createdAt: DateTime.parse(json['createdAt']),
//     updatedAt: DateTime.parse(json['updatedAt']),
//   );
//
//   ArticleDraft copyWith({
//     String? title,
//     String? content,
//     List<String>? imagePaths,
//     DateTime? updatedAt,
//   }) => ArticleDraft(
//     id: id,
//     title: title ?? this.title,
//     content: content ?? this.content,
//     imagePaths: imagePaths ?? this.imagePaths,
//     createdAt: createdAt,
//     updatedAt: updatedAt ?? this.updatedAt,
//   );
// }
//
// class DraftRepository {
//   static const String _draftKey = 'article_drafts';
//
//   Future<List<ArticleDraft>> getDrafts() async {
//     final prefs = await SharedPreferences.getInstance();
//     final draftsJson = prefs.getStringList(_draftKey) ?? [];
//     return draftsJson
//         .map((json) => ArticleDraft.fromJson(jsonDecode(json)))
//         .toList()
//       ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
//   }
//
//   Future<void> saveDraft(ArticleDraft draft) async {
//     final prefs = await SharedPreferences.getInstance();
//     final drafts = await getDrafts();
//
//     drafts.removeWhere((d) => d.id == draft.id);
//
//     drafts.insert(0, draft);
//
//     final draftsJson = drafts.map((d) => jsonEncode(d.toJson())).toList();
//     await prefs.setStringList(_draftKey, draftsJson);
//   }
//
//   Future<void> deleteDraft(String id) async {
//     final prefs = await SharedPreferences.getInstance();
//     final drafts = await getDrafts();
//     drafts.removeWhere((d) => d.id == id);
//
//     final draftsJson = drafts.map((d) => jsonEncode(d.toJson())).toList();
//     await prefs.setStringList(_draftKey, draftsJson);
//   }
// }
//
// final draftRepositoryProvider = Provider((ref) => DraftRepository());
//
// final draftsProvider = FutureProvider<List<ArticleDraft>>((ref) async {
//   final repo = ref.watch(draftRepositoryProvider);
//   return repo.getDrafts();
// });
