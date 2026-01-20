import 'package:writeit/data/models/article.dart';

abstract class SearchRepository {
  Future<List<Article>> searchArticles(String query);
}
