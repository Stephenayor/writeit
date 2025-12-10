import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:writeit/data/repositories/draft_repository.dart';
import 'package:writeit/domain/repo/DraftRepositoryImpl.dart';
import '../../data/repositories/article_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/repo/ArticleRepositoryImpl.dart';
import '../../domain/repo/AuthRepositoryImpl.dart';
import '../../domain/repo/ProfileRepositoryImpl.dart';
import '../utils/user_session_helper.dart';

final getIt = GetIt.instance;

void setupLocator() {
  //Register Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<DraftRepository>(() => DraftRepositoryImpl());
  getIt.registerLazySingleton<ArticleRepository>(() => ArticleRepositoryImpl());
  getIt.registerLazySingleton<UserSessionHelper>(
    () => UserSessionHelper(FirebaseAuth.instance),
  );
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl());
}
