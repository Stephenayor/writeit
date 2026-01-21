import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writeit/core/utils/dialogs/error_dialog.dart';
import 'package:writeit/presentation/publish/preview_card.dart';
import '../../core/network/api_response.dart';
import '../../core/utils/dialogs/show_loading.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        ErrorDialog.show(context, "Error  ", next.message);
      }

      if (next is Loading<String>) {
        AppLoadingDialog.show(
          context,
          message: "Publishing your unique story..",
        );
      } else {
        // Close loading dialog if it's open
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Article Preview"),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Preview card
          PreviewCard(title: title, images: images),

          const SizedBox(height: 20),

          // Category row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                "Category",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: selectedCategory == null
                  ? const Text(
                      "No category selected",
                      style: TextStyle(fontSize: 13),
                    )
                  : Text(selectedCategory.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push(Routes.selectCategoryScreen);
              },
            ),
          ),

          const Spacer(),

          // 🔹 Publish button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (selectedCategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Please select a category to complete the process",
                        ),
                      ),
                    );
                    return;
                  }

                  publish(context, ref);
                },
                child: const Text(
                  "Publish now",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void publish(BuildContext context, WidgetRef ref) async {
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
