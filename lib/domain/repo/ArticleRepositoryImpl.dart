import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:writeit/core/utils/constants.dart';
import 'package:writeit/data/repositories/article_repository.dart';

import '../../data/models/article.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  late String articleTitle;

  ArticleRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<String> publishArticle({
    required String title,
    required String rawContent,
    required List<String> localImagePaths,
    List<String>? tags,
    String? category,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    articleTitle = title;

    try {
      final articlesRef = _firestore.collection('articles');
      final articleDocRef = articlesRef.doc();
      final articleId = articleDocRef.id;

      final articleImageUrl = await _uploadArticleImages(
        authorId: user.uid,
        articleId: articleId,
        localImagePaths: localImagePaths,
      );

      print("Uploaded URLs: $articleImageUrl");
      final contentWithUrls = _replaceImageMarkersWithUrls(
        rawContent,
        articleImageUrl,
      );

      final userDocument = await _firestore
          .collection(Constants.writeITUsersTable)
          .doc(user.uid)
          .get();
      final authorName =
          userDocument.data()?['displayName'] ?? user.displayName ?? '';
      final authorPhotoUrl = userDocument.data()?['photoUrl'] ?? user.photoURL;
      final now = FieldValue.serverTimestamp();
      final readTimeMinutes = _estimateReadTimeMinutes(contentWithUrls);
      final coverImageUrl = articleImageUrl.isNotEmpty
          ? articleImageUrl.first
          : null;

      final article = Article(
        id: articleId,
        title: title,
        subtitle: null,
        content: contentWithUrls,
        coverImageUrl: coverImageUrl,
        authorId: user.uid,
        authorName: authorName,
        authorPhotoUrl: authorPhotoUrl,
        tags: tags ?? [],
        category: category,
        status: "published",
        readTimeMinutes: readTimeMinutes,
        likesCount: 0,
        commentsCount: 0,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        publishedAt: null,
      );

      await articleDocRef.set(article.toJson());
      return articleId;
    } catch (e, stack) {
      print("Error: $e");
      rethrow;
    }
  }

  Future<List<String>> _uploadArticleImages({
    required String authorId,
    required String articleId,
    required List<String> localImagePaths,
  }) async {
    print("Local paths received: $localImagePaths");
    if (localImagePaths.isEmpty) {
      return [];
    }
    final urls = <String>[];

    for (var i = 0; i < localImagePaths.length; i++) {
      final path = localImagePaths[i];
      final file = File(path);

      if (!file.existsSync()) {
        continue;
      }

      final fileName =
          '$articleTitle${DateTime.now().millisecondsSinceEpoch}${_auth.currentUser?.displayName}_$i.jpg';
      final firebaseStorageRef = _storage.ref(
        'article_images/$authorId/$articleId/$fileName',
      );

      final firebaseStoragePath =
          'article_images/$authorId/$articleId/$fileName';

      try {
        final uploadTask = _storage.ref(firebaseStoragePath).putFile(file);
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        urls.add(downloadUrl);
      } catch (e, stack) {
        print("Exception: $e");
        rethrow;
      }
    }

    print("✔ All uploaded URLs: $urls");
    return urls;
  }

  String _replaceImageMarkersWithUrls(String raw, List<String> imageUrls) {
    var result = raw;
    for (var i = 0; i < imageUrls.length; i++) {
      final marker = '[IMAGE:$i]';
      final markdown = '\n![](${imageUrls[i]})\n';
      result = result.replaceAll(marker, markdown);
    }
    return result;
  }

  int _estimateReadTimeMinutes(String content) {
    final words = content
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .length;
    const wordsPerMinute = 200;
    final minutes = (words / wordsPerMinute).ceil();
    return minutes == 0 ? 1 : minutes;
  }

  // @override
  // Future<String> publishArticle({
  //   required String title,
  //   required String rawContent,
  //   required List<String> localImagePaths,
  //   List<String>? tags,
  //   String? category,
  // }) async {
  //   final user = _auth.currentUser;
  //   if (user == null) {
  //     throw Exception('User not authenticated');
  //   }
  //
  //   // Prepare article doc reference so we know articleId ahead of time
  //   final articlesRef = _firestore.collection('articles');
  //   final articleDocRef = articlesRef.doc();
  //   final articleId = articleDocRef.id;
  //
  //   final articleImageUrl = await _uploadArticleImages(
  //     authorId: user.uid,
  //     articleId: articleId,
  //     localImagePaths: localImagePaths,
  //   );
  //   final contentWithUrls = _replaceImageMarkersWithUrls(
  //     rawContent,
  //     articleImageUrl,
  //   );
  //   final userDocument = await _firestore
  //       .collection(Constants.writeITUsersTable)
  //       .doc(user.uid)
  //       .get();
  //   final authorName =
  //       userDocument.data()?['displayName'] ?? user.displayName ?? '';
  //   final authorPhotoUrl = userDocument.data()?['photoUrl'] ?? user.photoURL;
  //   final now = FieldValue.serverTimestamp();
  //   final readTimeMinutes = _estimateReadTimeMinutes(contentWithUrls);
  //
  //   final coverImageUrl = articleImageUrl.isNotEmpty
  //       ? articleImageUrl.first
  //       : null;
  //
  //   final article = Article(
  //     id: articleId,
  //     title: title,
  //     subtitle: null,
  //     content: contentWithUrls,
  //     coverImageUrl: coverImageUrl,
  //     authorId: user.uid,
  //     authorName: authorName,
  //     authorPhotoUrl: authorPhotoUrl,
  //     tags: tags ?? [],
  //     category: category,
  //     status: "published",
  //     // or "draft" if i want to support remote drafts
  //     readTimeMinutes: readTimeMinutes,
  //     likesCount: 0,
  //     commentsCount: 0,
  //     createdAt: Timestamp.now(),
  //     updatedAt: Timestamp.now(),
  //     publishedAt: FieldValue.serverTimestamp() as Timestamp?,
  //   );
  //
  //   await articleDocRef.set(article.toJson());
  //
  //   return articleId;
  // }
}
