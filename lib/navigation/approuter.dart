import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:writeit/presentation/auth/signin/signin_screen.dart';
import 'package:writeit/presentation/auth/signup/signup_screen.dart';
import 'package:writeit/presentation/home/home_screen.dart';
import 'package:writeit/presentation/publish/create_article_screen.dart';
import 'package:writeit/presentation/publish/drafts/drafts_list_screen.dart';
import '../core/utils/routes.dart';
import '../splash_screen.dart';

final router = GoRouter(
  initialLocation: Routes.splashScreen,
  routes: [
    GoRoute(
      path: Routes.splashScreen,
      pageBuilder: (context, state) =>
          const CupertinoPage(child: SplashScreen()),
    ),
    GoRoute(
      path: Routes.signUp,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: Routes.signIn,
      builder: (context, state) => const SigninScreen(),
    ),
    GoRoute(
      path: Routes.createArticleScreen,
      builder: (context, state) {
        final data = state.extra as Map?;
        return CreateArticleScreen(
          draftId: data?['draftId'],
          existingContent: data?['content'],
          existingImages: data?['images'],
        );
      },
    ),
    GoRoute(
      path: Routes.draftsListScreen,
      builder: (context, state) => const DraftsListScreen(),
    ),
  ],
);
