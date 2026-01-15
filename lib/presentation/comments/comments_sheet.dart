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
    final comments = ref.watch(commentsStreamProvider(articleId));

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
                data: (comments) {
                  if (comments.isEmpty) {
                    return const Center(child: Text("No Comments Yet"));
                  }
                  return ListView.builder(
                    controller: controller,
                    itemCount: comments.length,
                    itemBuilder: (_, i) =>
                        CommentTile(articleId: articleId, comment: comments[i]),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Failed to Load Comments")),
              ),
            ),
            CommentInput(articleId: articleId),
          ],
        );
      },
    );
  }
}
