import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/comment.dart';
import '../../../data/repositories/comment_repository.dart';

class RepliesNotifier extends StateNotifier<AsyncValue<List<Comment>>> {
  final CommentRepository repo;
  final String articleId;
  final String commentId;

  RepliesNotifier(this.repo, this.articleId, this.commentId)
    : super(const AsyncLoading()) {
    // Changed to AsyncLoading
    load(); // Call load immediately
  }

  Future<void> load() async {
    try {
      state = const AsyncLoading();
      final replies = await repo.getReplies(articleId, commentId);
      state = AsyncData(replies);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addReply(String text) async {
    final prev = state.value ?? [];
    final updateCommentWithReply = Comment(
      id: UniqueKey().toString(),
      userId: FirebaseAuth.instance.currentUser!.uid,
      text: text,
      createdAt: DateTime.now(),
      likesCount: 0,
      repliesCount: 0,
      userName: FirebaseAuth.instance.currentUser!.displayName!,
      avatarUrl: FirebaseAuth.instance.currentUser!.photoURL!,
    );

    state = AsyncData([...prev, updateCommentWithReply]);

    try {
      await repo.addReply(articleId, commentId, text);
      await load();
    } catch (_) {
      state = AsyncData(prev);
    }
  }
}

// class RepliesNotifier extends StateNotifier<AsyncValue<List<Reply>>> {
//   final Ref ref;
//   final ReplyArgs args;
//
//   RepliesNotifier(this.ref, this.args) : super(const AsyncLoading()) {
//     _load();
//   }
//
//   Future<void> _load() async {
//     try {
//       final repo = ref.read(commentRepositoryProvider);
//
//       final replies = await repo.getReplies(args.articleId, args.commentId);
//
//       state = AsyncData(replies);
//     } catch (e, st) {
//       state = AsyncError(e, st);
//     }
//   }
//
//   Future<void> addReply(String text) async {
//     await ref
//         .read(commentRepositoryProvider)
//         .addReply(args.articleId, args.commentId, text);
//
//     // Reload after adding
//     _load();
//   }
// }
