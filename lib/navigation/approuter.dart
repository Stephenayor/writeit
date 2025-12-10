import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:writeit/presentation/auth/signin/signin_screen.dart';
import 'package:writeit/presentation/auth/signup/signup_screen.dart';
import 'package:writeit/presentation/home/home_screen.dart';
import 'package:writeit/presentation/profile/edit_profile_screen.dart';
import 'package:writeit/presentation/profile/profile_screen.dart';
import 'package:writeit/presentation/publish/create_article_screen.dart';
import 'package:writeit/presentation/publish/drafts/drafts_list_screen.dart';
import '../core/utils/routes.dart';
import '../data/models/article.dart';
import '../presentation/publish/detail/article_detail_screen.dart';
import '../splash_screen.dart';

// final router = GoRouter(
//   initialLocation: Routes.splashScreen,
//   routes: [
//     GoRoute(
//       path: Routes.splashScreen,
//       pageBuilder: (context, state) =>
//           const CupertinoPage(child: SplashScreen()),
//     ),
//     GoRoute(
//       path: Routes.signUp,
//       builder: (context, state) => const SignupScreen(),
//     ),
//     GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
//     GoRoute(
//       path: Routes.signIn,
//       builder: (context, state) => const SigninScreen(),
//     ),
//     GoRoute(
//       path: Routes.createArticleScreen,
//       builder: (context, state) {
//         final data = state.extra as Map?;
//         return CreateArticleScreen(
//           draftId: data?['draftId'],
//           existingContent: data?['content'],
//           existingImages: data?['images'],
//         );
//       },
//     ),
//     GoRoute(
//       path: Routes.draftsListScreen,
//       builder: (context, state) => DraftsListScreen(),
//     ),
//     GoRoute(
//       path: Routes.articlesDetailScreen,
//       builder: (context, state) {
//         final article = state.extra as Article;
//         return ArticleDetailScreen(article: article);
//       },
//     ),
//     GoRoute(
//       path: Routes.profileScreen,
//       builder: (context, state) => ProfileScreen(),
//     ),
//     GoRoute(
//       path: Routes.editProfileScreen,
//       builder: (context, state) =>
//           EditProfileScreen(name: '', email: '', bio: ''),
//     ),
//   ],
// );

final router = GoRouter(
  initialLocation: Routes.splashScreen,
  routes: [
    GoRoute(
      path: Routes.splashScreen,
      name: 'splash',
      pageBuilder: (context, state) =>
          const CupertinoPage(child: SplashScreen()),
    ),

    GoRoute(
      path: Routes.signUp,
      name: 'sign-up',
      builder: (context, state) => const SignupScreen(),
    ),

    GoRoute(
      path: Routes.signIn,
      name: 'sign-in',
      builder: (context, state) => const SigninScreen(),
    ),

    GoRoute(
      path: Routes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: Routes.draftsListScreen,
      name: 'drafts-list',
      builder: (context, state) => DraftsListScreen(),
    ),

    GoRoute(
      path: Routes.createArticleScreen,
      name: 'create-article',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;

        return CreateArticleScreen(
          draftId: data?['draftId'],
          existingContent: data?['content'],
          existingImages: data?['images'],
        );
      },
    ),

    GoRoute(
      path: Routes.articlesDetailScreen,
      name: 'article-detail',
      builder: (context, state) {
        final article = state.extra as Article;
        return ArticleDetailScreen(article: article);
      },
    ),

    GoRoute(
      path: Routes.profileScreen,
      name: 'profile',
      builder: (context, state) => ProfileScreen(),
    ),

    GoRoute(
      path: Routes.editProfileScreen,
      name: 'edit-profile',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;

        return EditProfileScreen(
          name: data['name'],
          email: data['email'],
          bio: data['bio'],
          photoUrl: data['photoUrl'],
        );
      },
    ),
  ],
);
