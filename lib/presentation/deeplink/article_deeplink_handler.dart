import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/routes.dart';

class ArticleDeepLinkHandler extends ConsumerWidget {
  final String articleId;

  const ArticleDeepLinkHandler({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user == null) {
        context.go(
          Routes.signIn,
          extra: {"redirectTo": "/article/$articleId/read"},
        );
      } else {
        context.go("/article/$articleId/read");
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
