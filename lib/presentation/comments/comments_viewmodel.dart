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
