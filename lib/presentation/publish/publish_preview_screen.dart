import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writeit/presentation/publish/preview_card.dart';

import '../../core/network/api_response.dart';
import '../../core/utils/routes.dart';
import '../../providers/providers.dart';

class PublishPreviewScreen extends ConsumerWidget {
  final String title;
  final String content;
  final List<String> images;
  final String? draftID;

  const PublishPreviewScreen({
    super.key,
    required this.title,
    required this.content,
    required this.images,
    required this.draftID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    ref.listen<ApiResponse<String>>(articlePublishProvider, (prev, next) async {
      if (next is Success<String>) {
        if (draftID != null) {
          await ref
              .read(draftsViewModelProvider.notifier)
              .deleteDraft(draftID!);
        }
        ref.read(selectedCategoryProvider.notifier).state = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article published successfully')),
        );

        context.go(Routes.home);
      } else if (next is Failure<String>) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Article Preview"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // 🔹 Preview card
          PreviewCard(title: title, images: images),

          const SizedBox(height: 16),

          // 🔹 Category row
          ListTile(
            title: const Text("Category"),
            subtitle: selectedCategory == null
                ? const Text("No category selected")
                : Text(selectedCategory.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/select-category');
            },
          ),

          const Spacer(),

          // 🔹 Publish button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: selectedCategory == null
                    ? null
                    : () => _publish(context, ref),
                child: const Text("Publish now"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _publish(BuildContext context, WidgetRef ref) async {
    final publisher = ref.read(articlePublishProvider.notifier);
    final category = ref.read(selectedCategoryProvider)!;

    await publisher.publishArticle(
      title: title,
      rawContent: content,
      localImagePaths: images,
      category: category.name,
    );
  }
}
