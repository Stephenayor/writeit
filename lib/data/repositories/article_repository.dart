abstract class ArticleRepository {
  Future<String> publishArticle({
    required String title,
    required String rawContent,
    required List<String> localImagePaths,
    List<String>? tags,
    String? category,
  });
}
