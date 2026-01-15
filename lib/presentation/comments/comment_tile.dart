import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        : const AsyncData(<Comment>[]);

    final currentUser = ref.watch(userSessionProvider);
    final avatarUrl = widget.comment.avatarUrl;

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
        Row(
          children: [
            TextButton(
              child: Text("${widget.comment.repliesCount} replies"),
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

        if (expanded)
          repliesState.when(
            data: (list) => Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: list
                    .map(
                      (r) => ListTile(
                        title: Text(r.userId),
                        subtitle: Text(r.text),
                      ),
                    )
                    .toList(),
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),
            error: (_, __) => const Text("Failed to Load Replies"),
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

                  //Add the reply
                  // await ref
                  //     .read(
                  //       repliesProvider(
                  //         ReplyArgs(widget.articleId, widget.comment.id),
                  //       ),
                  //     )
                  //     .addReply(text);

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

  Future<void> addReply(String articleId, String commentId, String text) async {
    await FirebaseFirestore.instance
        .collection(Constants.articles)
        .doc(articleId)
        .collection(Constants.comments)
        .doc(commentId)
        .collection(Constants.replies)
        .add({
          'text': text,
          'createdAt': FieldValue.serverTimestamp(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
        });

    // Also increment repliesCount on parent comment
    await FirebaseFirestore.instance
        .collection(Constants.articles)
        .doc(articleId)
        .collection(Constants.comments)
        .doc(commentId)
        .update({'repliesCount': FieldValue.increment(1)});
  }
}
