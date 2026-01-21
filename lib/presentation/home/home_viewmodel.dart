import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/article.dart';
import '../../data/repositories/article_repository.dart';

class HomeViewmodel extends StateNotifier<AsyncValue<List<Article>>> {
  final ArticleRepository articleRepository;
  StreamSubscription<List<Article>>? _sub;

  HomeViewmodel(this.articleRepository) : super(const AsyncLoading()) {
    _listen();
  }

  void _listen() {
    _sub = articleRepository.fetchLatestArticles().listen(
      (articles) {
        state = AsyncData(articles);
      },
      onError: (e, st) {
        state = AsyncError(e, st);
      },
    );
  }

  Future<void> deleteArticle(String articleId) async {
    await articleRepository.deleteArticle(articleId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
