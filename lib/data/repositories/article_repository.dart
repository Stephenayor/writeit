import 'package:writeit/data/models/article.dart';

abstract class ArticleRepository {
  Future<String> publishArticle({
    required String title,
    required String rawContent,
    required List<String> localImagePaths,
    List<String>? tags,
    String? category,
  });

  Stream<List<Article>> fetchLatestArticles();
  Future<List<Article>> fetchArticlesByCategory(String category);
  Future<List<Article>> fetchArticlesByTag(String tag);
}
