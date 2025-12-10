import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:writeit/core/di/locator.dart';
import 'package:writeit/core/network/api_response.dart';
import 'package:writeit/data/repositories/auth_repository.dart';
import 'package:writeit/domain/repo/ProfileRepositoryImpl.dart';
import 'package:writeit/presentation/home/home_viewmodel.dart';
import 'package:writeit/presentation/publish/drafts/draft_save_state.dart';
import '../core/utils/user_session_helper.dart';
import '../data/models/app_user.dart';
import '../data/models/article.dart';
import '../data/models/draft.dart';
import '../data/repositories/article_repository.dart';
import '../data/repositories/draft_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../domain/repo/AuthRepositoryImpl.dart';
import '../domain/repo/DraftRepositoryImpl.dart';
import '../presentation/auth/signin/signin_state.dart';
import '../presentation/auth/signin/signinviewmodel.dart';
import '../presentation/auth/signup/signup_state.dart';
import '../presentation/auth/signup/signup_viewmodel.dart';
import '../presentation/profile/profile_viewmodel.dart';
import '../presentation/publish/create_article_viewmodel.dart';
import '../presentation/publish/drafts/drafts_viewmodel.dart';

final signupViewModelProvider =
    StateNotifierProvider<SignupViewModel, SignupState>((ref) {
      final authRepo = getIt<AuthRepository>();
      return SignupViewModel(authRepo);
    });

final signinViewModelProvider =
    StateNotifierProvider<SigninViewModel, SigninState>((ref) {
      return SigninViewModel(AuthRepositoryImpl());
    });

final draftsViewModelProvider =
    StateNotifierProvider<DraftsViewModel, DraftSaveState>((ref) {
      final draftsRepository = getIt<DraftRepository>();
      return DraftsViewModel(draftsRepository);
    });

final articlePublishProvider =
    StateNotifierProvider<CreateArticleViewModel, ApiResponse<String>>((ref) {
      final repo = getIt<ArticleRepository>();
      return CreateArticleViewModel(repo);
    });

// final homeViewModelProvider1 =
//     StateNotifierProvider<HomeViewmodel, AsyncValue<List<Article>>>((ref) {
//       final repo = getIt<ArticleRepository>();
//       return HomeViewmodel(repo);
//     });

final homeViewModelProvider = StreamProvider.autoDispose((ref) {
  final repo = getIt<ArticleRepository>();
  return repo.fetchLatestArticles();
});

final userSessionProvider = StateNotifierProvider<UserSessionHelper, AppUser?>(
  (ref) => getIt<UserSessionHelper>(),
);

final profileStreamProvider = StreamProvider<AppUser?>((ref) {
  final repo = getIt<ProfileRepository>();
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) return null;
    return await repo.fetchUser();
  });
});

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, AsyncValue<AppUser>>((ref) {
      final repo = getIt<ProfileRepository>();
      return ProfileViewModel(repo);
    });
