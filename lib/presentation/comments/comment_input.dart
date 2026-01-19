import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../providers/providers.dart';

class CommentInput extends ConsumerWidget {
  final String articleId;

  CommentInput({super.key, required this.articleId});

  final _controller = TextEditingController();
  final sendingCommentProvider = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSending = ref.watch(sendingCommentProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Write a comment...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),

          if (isSending)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                final text = _controller.text.trim();
                if (text.isEmpty) return;

                ref.read(sendingCommentProvider.notifier).state = true;

                try {
                  await ref
                      .read(commentRepositoryProvider)
                      .addComment(articleId, text);

                  _controller.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to send comment")),
                  );
                } finally {
                  ref.read(sendingCommentProvider.notifier).state = false;
                }
              },
            ),
        ],
      ),
    );
  }
}
