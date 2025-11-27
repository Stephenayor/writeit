import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/models/article.dart';
import '../../data/repositories/article_repository.dart';

class HomeViewmodel extends StateNotifier<AsyncValue<Stream<List<Article>>>> {
  final ArticleRepository _repo;

  HomeViewmodel(this._repo) : super(const AsyncLoading()) {
    loadArticles();
  }

  Future<void> loadArticles() async {
    try {
      final articles = await _repo.fetchLatestArticles();
      state = AsyncValue.data(articles);
    } catch (e, stack) {
      print(e.toString());
      print(stack.toString());
      state = AsyncValue.error(e, stack);
    }
  }
}
