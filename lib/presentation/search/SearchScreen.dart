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
    final searchState = ref.watch(searchViewModelProvider);
    final searchViewModel = ref.read(searchViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore"),
        centerTitle: false,
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search Field
            TextField(
              controller: controller,
              onChanged: searchViewModel.onQueryChanged,
              decoration: InputDecoration(
                hintText: "Search for articles",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          controller.clear();
                          searchViewModel.onQueryChanged("");
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
            if (searchState.query.isEmpty && searchState.recent.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent searches",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: searchViewModel.clearRecent,
                    child: const Text("Clear all"),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: searchState.recent
                    .map(
                      (r) => ActionChip(
                        label: Text(r),
                        onPressed: () {
                          controller.text = r;
                          searchViewModel.tapRecent(r);
                        },
                      ),
                    )
                    .toList(),
              ),
            ],

            // 📃 Results
            if (searchState.query.isNotEmpty) ...[
              const SizedBox(height: 12),
              if (searchState.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: searchState.results.length,
                    itemBuilder: (_, i) {
                      final articles = searchState.results[i];
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
