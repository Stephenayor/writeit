import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class CommentInput extends ConsumerStatefulWidget {
  final String articleId;
  final String? replyingTo;

  const CommentInput({super.key, required this.articleId, this.replyingTo});

  @override
  ConsumerState<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends ConsumerState<CommentInput> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userSessionProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: widget.replyingTo != null
                      ? "Replying to @${widget.replyingTo}"
                      : "Add a response...",
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                ref
                    .read(commentsProvider(widget.articleId).notifier)
                    .addComment(controller.text, currentUser!.displayName!);
                controller.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
