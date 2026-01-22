import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writeit/data/models/reply.dart';
import '../../core/utils/constants.dart';
import '../../data/models/comment.dart';
import '../../data/models/reply_args.dart';
import '../../providers/providers.dart';

class CommentTile extends ConsumerStatefulWidget {
  final String articleId;
  final Comment comment;

  const CommentTile({
    super.key,
    required this.articleId,
    required this.comment,
  });

  @override
  ConsumerState<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<CommentTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final repliesState = expanded
        ? ref.watch(
            repliesProvider(ReplyArgs(widget.articleId, widget.comment.id)),
          )
        : const AsyncData(<Reply>[]);

    final currentUser = ref.watch(userSessionProvider);
    final avatarUrl = widget.comment.avatarUrl;
    String replyCountText;
    if (widget.comment.repliesCount > 1) {
      replyCountText = "replies";
    } else {
      replyCountText = "reply";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null ? const Icon(Icons.person) : null,
              ),

              const SizedBox(width: 12),

              // Name + time + comment
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.comment.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeAgo(widget.comment.createdAt),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Comment text
                    Text(
                      widget.comment.text,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 52.0),
          child: Row(
            children: [
              TextButton(
                child: Text("${widget.comment.repliesCount} $replyCountText"),
                onPressed: () {
                  setState(() => expanded = !expanded);
                },
              ),
              TextButton(
                child: const Text("Reply"),
                onPressed: () {
                  showReplyInput(context, widget.comment);
                },
              ),
            ],
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: repliesState.when(
              data: (list) => Column(
                children: list.map((reply) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundImage: reply.avatarUrl != null
                          ? NetworkImage(reply.avatarUrl!)
                          : null,
                      child: reply.avatarUrl == null
                          ? const Icon(Icons.person, size: 14)
                          : null,
                    ),
                    title: Text(reply.userName),
                    subtitle: Text(reply.text),
                  );
                }).toList(),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
              error: (e, st) => Text("Failed to load replies: $e"),
            ),
          ),
      ],
    );
  }

  void showReplyInput(BuildContext context, Comment comment) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Replying to @${widget.comment.userName}",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;

                  // Close the modal
                  Navigator.of(modalContext).pop();

                  addReply(
                    widget.articleId,
                    widget.comment.id,
                    controller.text,
                  );

                  // Expand to show the new reply
                  if (!expanded) {
                    setState(() => expanded = true);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "just now";
  }
}

Future<void> addReply(String articleId, String commentId, String text) async {
  await FirebaseFirestore.instance
      .collection(Constants.articles)
      .doc(articleId)
      .collection(Constants.comments)
      .doc(commentId)
      .collection(Constants.replies)
      .add({
        'id': UniqueKey().toString(),
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'userName':
            FirebaseAuth.instance.currentUser!.displayName ?? 'Anonymous',
        'avatarUrl': FirebaseAuth.instance.currentUser!.photoURL,
      });

  // Also increment repliesCount on parent comment
  FirebaseFirestore.instance
      .collection(Constants.articles)
      .doc(articleId)
      .collection(Constants.comments)
      .doc(commentId);
}
