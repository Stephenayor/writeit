import 'package:flutter_riverpod/legacy.dart';
import 'package:writeit/core/network/api_response.dart';
import 'package:writeit/data/repositories/article_repository.dart';

class CreateArticleViewModel extends StateNotifier<ApiResponse<String>> {
  final ArticleRepository articleRepository;

  CreateArticleViewModel(this.articleRepository) : super(Idle<String>());

  Future<void> publishArticle({
    required String title,
    required String rawContent,
    required List<String> localImagePaths,
  }) async {
    if (title.trim().isEmpty && rawContent.trim().isEmpty) {
      state = Failure<String>("Article cannot be empty");
      return;
    }

    state = Loading<String>();

    try {
      final articleId = await articleRepository.publishArticle(
        title: title,
        rawContent: rawContent,
        localImagePaths: localImagePaths,
      );
      state = Success<String>(articleId);
    } catch (e) {
      state = Failure<String>(
        "Failed to publish article. Please try again.",
        error: e,
      );
    }
  }

  void reset() {
    state = Idle<String>();
  }
}
