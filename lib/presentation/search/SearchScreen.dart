import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:writeit/core/utils/routes.dart';
import '../../core/utils/view/article_card.dart';
import '../../providers/providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchViewModelProvider);
    final vm = ref.read(searchViewModelProvider.notifier);
    final searchState = ref.watch(searchViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Explore"), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search Field
            TextField(
              controller: controller,
              onChanged: vm.onQueryChanged,
              decoration: InputDecoration(
                hintText: "Search for articles",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          controller.clear();
                          vm.onQueryChanged("");
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🕘 Recent Searches
            if (state.query.isEmpty && state.recent.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent searches",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: vm.clearRecent,
                    child: const Text("Clear all"),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.recent
                    .map(
                      (r) => ActionChip(
                        label: Text(r),
                        onPressed: () {
                          controller.text = r;
                          vm.tapRecent(r);
                        },
                      ),
                    )
                    .toList(),
              ),
            ],

            // 📃 Results
            if (state.query.isNotEmpty) ...[
              const SizedBox(height: 12),
              if (state.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: state.results.length,
                    itemBuilder: (_, i) {
                      final articles = state.results[i];
                      return ArticleCard(article: articles, isDark: isDark);
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
