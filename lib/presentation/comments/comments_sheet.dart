import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import 'comment_input.dart';
import 'comment_tile.dart';

class CommentsSheet extends ConsumerWidget {
  final String articleId;
  const CommentsSheet({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(commentsProvider(articleId));

    return DraggableScrollableSheet(
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              "Responses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: comments.when(
                data: (list) => ListView.builder(
                  controller: controller,
                  itemCount: list.length,
                  itemBuilder: (_, i) =>
                      CommentTile(articleId: articleId, comment: list[i]),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Failed to load comments")),
              ),
            ),
            CommentInput(articleId: articleId),
          ],
        );
      },
    );
  }
}
