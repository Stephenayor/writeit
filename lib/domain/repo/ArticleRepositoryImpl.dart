import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:writeit/core/utils/constants.dart';
import 'package:writeit/data/repositories/article_repository.dart';

import '../../core/utils/helper/image_persistence_helper.dart';
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
        publishedAt: Timestamp.now(),
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

    final urls = <String>[];

    for (var i = 0; i < localImagePaths.length; i++) {
      final filename = localImagePaths[i];

      // Convert filename to actual file path
      final file = await ImagePersistenceHelper.getImageFile(filename);

      if (file == null || !await file.exists()) {
        print("File does not exist: $filename");
        continue;
      }

      final fileName =
          '$articleTitle${DateTime.now()}_${_auth.currentUser?.uid}_$i.jpg';

      final storageRef = _storage.ref('article_images/$fileName');

      try {
        final uploadTask = await storageRef.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        urls.add(downloadUrl);
        print("Uploaded $fileName → $downloadUrl");
      } catch (e) {
        print("Upload failed for $filename → $e");
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

  @override
  Future<List<Article>> fetchArticlesByCategory(String category) async {
    final snapshot = await _firestore
        .collection(Constants.articles)
        .where('status', isEqualTo: 'published')
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs
        .map((d) => Article.fromJson(d.data(), snapshot.docs.single.id))
        .toList();
  }

  @override
  Future<List<Article>> fetchArticlesByTag(String tag) async {
    final snapshot = await _firestore
        .collection(Constants.articles)
        .where('status', isEqualTo: 'published')
        .where('tags', arrayContains: tag)
        .get();
    return snapshot.docs
        .map((d) => Article.fromJson(d.data(), snapshot.docs.single.id))
        .toList();
  }

  @override
  Stream<List<Article>> fetchLatestArticles() {
    return _firestore
        .collection(Constants.articles)
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Article.fromJson(doc.data(), doc.id))
              .toList();
        });
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
