import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:writeit/core/di/locator.dart';
import 'package:writeit/core/network/api_response.dart';
import 'package:writeit/data/repositories/auth_repository.dart';
import 'package:writeit/presentation/publish/drafts/draft_save_state.dart';
import '../core/notifications/notifications_notifier.dart';
import '../core/utils/user_session_helper.dart';
import '../data/models/app_user.dart';
import '../data/models/category.dart';
import '../data/models/comment.dart';
import '../data/models/reply.dart';
import '../data/models/reply_args.dart';
import '../data/repositories/article_repository.dart';
import '../data/repositories/comment_repository.dart';
import '../data/repositories/draft_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../domain/repo/AuthRepositoryImpl.dart';
import '../domain/repo/CommentRepositoryImpl.dart';
import '../presentation/auth/signin/signin_state.dart';
import '../presentation/auth/signin/signinviewmodel.dart';
import '../presentation/auth/signup/signup_state.dart';
import '../presentation/auth/signup/signup_viewmodel.dart';
import '../presentation/comments/comments_viewmodel.dart';
import '../presentation/comments/replies/replies_viewmodel.dart';
import '../presentation/profile/profile_viewmodel.dart';
import '../presentation/publish/create_article_viewmodel.dart';
import '../presentation/publish/drafts/drafts_viewmodel.dart';

final signupViewModelProvider =
    StateNotifierProvider<SignupViewModel, SignupState>((ref) {
      final authRepo = getIt<AuthRepository>();
      return SignupViewModel(authRepo);
    });

final signInViewModelProvider =
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

final homeViewModelProvider = StreamProvider.autoDispose((ref) {
  final repo = getIt<ArticleRepository>();
  return repo.fetchLatestArticles();
});

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

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, bool>((ref) {
      return NotificationsNotifier();
    });

final categoriesProvider = Provider<List<Category>>((ref) {
  return [
    Category(id: "tech", name: "Technology"),
    Category(id: "business", name: "Business"),
    Category(id: "life", name: "Lifestyle"),
    Category(id: "programming", name: "Programming"),
  ];
});

final selectedCategoryProvider = StateProvider<Category?>((ref) => null);

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepositoryImpl();
});

final commentsProvider =
    StateNotifierProvider.family<
      CommentsNotifier,
      AsyncValue<List<Comment>>,
      String
    >((ref, articleId) {
      final repo = ref.read(commentRepositoryProvider);
      return CommentsNotifier(repo, articleId);
    });

final repliesProvider = StreamProvider.family<List<Reply>, ReplyArgs>((
  ref,
  args,
) {
  final repo = ref.watch(commentRepositoryProvider);
  return repo.watchReplies(args.articleId, args.commentId);
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final userSessionProvider = StateNotifierProvider<UserSessionHelper, AppUser?>((
  ref,
) {
  final auth = ref.watch(firebaseAuthProvider);
  return UserSessionHelper(auth);
});

final commentsStreamProvider = StreamProvider.family<List<Comment>, String>((
  ref,
  articleId,
) {
  final repo = ref.watch(commentRepositoryProvider);
  return repo.fetchComments(articleId);
});
