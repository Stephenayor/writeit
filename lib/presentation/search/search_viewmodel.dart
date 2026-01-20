import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:writeit/presentation/search/search_state.dart';

import '../../data/repositories/search_repository.dart';

class SearchViewModel extends StateNotifier<SearchState> {
  final SearchRepository repo;

  SearchViewModel(this.repo) : super(SearchState.initial());

  Timer? _debounce;

  void onQueryChanged(String value) {
    state = state.copyWith(query: value);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(value);
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(results: []);
      return;
    }

    state = state.copyWith(isLoading: true);

    final results = await repo.searchArticles(query);

    state = state.copyWith(
      isLoading: false,
      results: results,
      recent: {query, ...state.recent}.toList().take(8).toList(),
    );
  }

  void clearRecent() {
    state = state.copyWith(recent: []);
  }

  void tapRecent(String q) {
    onQueryChanged(q);
  }
}
