class ReplyArgs {
  final String articleId;
  final String commentId;

  const ReplyArgs(this.articleId, this.commentId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReplyArgs &&
        other.articleId == articleId &&
        other.commentId == commentId;
  }

  @override
  int get hashCode => Object.hash(articleId, commentId);
}
