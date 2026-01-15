import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/comment.dart';
import '../../data/repositories/comment_repository.dart';

class CommentsNotifier extends StateNotifier<AsyncValue<List<Comment>>> {
  final CommentRepository repo;
  final String articleId;

  CommentsNotifier(this.repo, this.articleId) : super(const AsyncLoading()) {
    getComments();
  }

  Future<void> getComments() async {
    final comments = await repo.getComments(articleId);
    state = AsyncData(comments);
  }

  Future<void> addComment(String text, String userName) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final tempId = UniqueKey().toString();
    final prev = state.value ?? [];
    final comment = Comment(
      id: tempId,
      userId: uid,
      userName: userName,
      text: text,
      createdAt: DateTime.now(),
      likesCount: 0,
      repliesCount: 0,
      avatarUrl: FirebaseAuth.instance.currentUser!.photoURL!,
    );

    state = AsyncData([comment, ...prev]);

    try {
      await repo.addComment(articleId, text);
      await getComments(); // resync
    } catch (_) {
      state = AsyncData(prev); // rollback
    }
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../data/models/comment.dart';
// import '../../data/repositories/comment_repository.dart';
//
// class CommentsNotifier extends StreamNotifier<List<Comment>> {
//   final CommentRepository repo;
//   final String articleId;
//
//   CommentsNotifier(this.repo, this.articleId);
//
//   @override
//   Stream<List<Comment>> build() {
//     // Return the stream - Riverpod handles the subscription
//     return repo.getComments(articleId);
//   }
//
//   Future<void> addComment(String text, String userName) async {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final tempId = UniqueKey().toString();
//
//     final optimisticComment = Comment(
//       id: tempId,
//       userId: uid,
//       userName: userName,
//       text: text,
//       createdAt: DateTime.now(),
//       likesCount: 0,
//       repliesCount: 0,
//       avatarUrl: FirebaseAuth.instance.currentUser!.photoURL ?? '',
//     );
//
//     // Get current state
//     final currentState = state;
//
//     // Optimistically update UI
//     if (currentState is AsyncData<List<Comment>>) {
//       state = AsyncData([optimisticComment, ...currentState.value]);
//     }
//
//     try {
//       await repo.addComment(articleId, text);
//       // Stream will sync the real data from Firebase
//     } catch (e) {
//       // Rollback on error
//       state = currentState;
//       rethrow;
//     }
//   }
// }
