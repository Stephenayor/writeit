import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writeit/core/utils/constants.dart';

import '../../data/models/comment.dart';
import '../../data/repositories/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Future<void> toggleLike(String articleId, String userId) async {
    final doc = FirebaseFirestore.instance
        .collection(Constants.articles)
        .doc(articleId)
        .collection(Constants.likes)
        .doc(userId);

    final articleRef = FirebaseFirestore.instance
        .collection(Constants.articles)
        .doc(articleId);

    FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(doc);

      if (snap.exists) {
        tx.delete(doc);
        tx.update(articleRef, {'likesCount': FieldValue.increment(-1)});
      } else {
        tx.set(doc, {'createdAt': FieldValue.serverTimestamp()});
        tx.update(articleRef, {'likesCount': FieldValue.increment(1)});
      }
    });
  }

  @override
  Future<void> addComment(String articleId, String text) async {
    final ref = FirebaseFirestore.instance
        .collection(Constants.articles)
        .doc(articleId)
        .collection(Constants.comments)
        .doc();

    await FirebaseFirestore.instance.runTransaction((tx) async {
      tx.set(ref, {
        'id': ref.id,
        'userId': currentUserId,
        'userName': currentUser?.displayName,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': 0,
        'repliesCount': 0,
        'avatarUrl': currentUser?.photoURL,
      });

      tx.update(
        FirebaseFirestore.instance
            .collection(Constants.articles)
            .doc(articleId),
        {'commentsCount': FieldValue.increment(1)},
      );
    });
  }

  @override
  Future<void> addReply(String articleId, String commentId, String text) async {
    final ref = FirebaseFirestore.instance
        .collection(Constants.articles)
        .doc(articleId)
        .collection(Constants.comments)
        .doc(commentId)
        .collection(Constants.replies)
        .doc();

    await FirebaseFirestore.instance.runTransaction((tx) async {
      tx.set(ref, {
        'id': ref.id,
        'userId': currentUserId,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      tx.update(
        FirebaseFirestore.instance
            .collection(Constants.articles)
            .doc(articleId)
            .collection(Constants.comments)
            .doc(commentId),
        {'repliesCount': FieldValue.increment(1)},
      );
    });
  }

  Future<void> toggleCommentLike(String articleId, String commentId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final likeRef = FirebaseFirestore.instance
        .collection(Constants.articles)
        .doc(articleId)
        .collection(Constants.comments)
        .doc(commentId)
        .collection(Constants.likes)
        .doc(uid);

    final commentRef = FirebaseFirestore.instance
        .collection(Constants.articles)
        .doc(articleId)
        .collection(Constants.comments)
        .doc(commentId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(likeRef);
      if (snap.exists) {
        tx.delete(likeRef);
        tx.update(commentRef, {'likesCount': FieldValue.increment(-1)});
      } else {
        tx.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
        tx.update(commentRef, {'likesCount': FieldValue.increment(1)});
      }
    });
  }

  // @override
  // Stream<List<Comment>> getComments(String articleId) {
  //   return FirebaseFirestore.instance
  //       .collection(Constants.articles)
  //       .doc(articleId)
  //       .collection(Constants.comments)
  //       .orderBy('createdAt', descending: true)
  //       .snapshots()
  //       .map(
  //         (snapshot) =>
  //             snapshot.docs.map((doc) => Comment.fromDoc(doc)).toList(),
  //       );
  // }

  @override
  Future<List<Comment>> getComments(String articleId) async {
    final snap = await FirebaseFirestore.instance
        .collection(Constants.articles)
        .doc(articleId)
        .collection(Constants.comments)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((e) => Comment.fromDoc(e)).toList();
  }

  @override
  Future<List<Comment>> getReplies(String articleId, String commentId) async {
    final snap = await FirebaseFirestore.instance
        .collection(Constants.articles)
        .doc(articleId)
        .collection(Constants.comments)
        .doc(commentId)
        .collection(Constants.replies)
        .orderBy('createdAt')
        .get();

    return snap.docs.map((e) => Comment.fromDoc(e)).toList();
  }

  @override
  Stream<List<Comment>> watchReplies(String articleId, String commentId) {
    return FirebaseFirestore.instance
        .collection(Constants.articles)
        .doc(articleId)
        .collection(Constants.comments)
        .doc(commentId)
        .collection(Constants.replies)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map((e) => Comment.fromDoc(e)).toList());
  }
}
