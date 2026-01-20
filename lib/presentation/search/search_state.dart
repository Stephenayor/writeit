import '../../data/models/article.dart';

class SearchState {
  final bool isLoading;
  final List<Article> results;
  final List<String> recent;
  final String query;

  SearchState({
    required this.isLoading,
    required this.results,
    required this.recent,
    required this.query,
  });

  factory SearchState.initial() =>
      SearchState(isLoading: false, results: [], recent: [], query: "");

  SearchState copyWith({
    bool? isLoading,
    List<Article>? results,
    List<String>? recent,
    String? query,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      recent: recent ?? this.recent,
      query: query ?? this.query,
    );
  }
}
