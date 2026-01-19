import 'package:writeit/data/models/reply.dart';

import '../models/comment.dart';

abstract class CommentRepository {
  Future<void> toggleLike(String articleId, String userId) async {}
  Future<void> addComment(String articleId, String text) async {}
  Future<void> addReply(
    String articleId,
    String commentId,
    String text,
  ) async {}
  Future<List<Comment>> getComments(String articleId);
  Stream<List<Comment>> fetchComments(String articleId);
  Stream<List<Reply>> fetchReplies(String articleId, String commentId);
}
