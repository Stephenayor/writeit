import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../publish/detail/article_detail_screen.dart';

class ArticleDetailByIdScreen extends ConsumerWidget {
  final String articleId;

  const ArticleDetailByIdScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleByIdProvider(articleId));

    return articleAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text("Error loading article"))),
      data: (article) => ArticleDetailScreen(article: article),
    );
  }
}
