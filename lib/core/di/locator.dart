import 'package:get_it/get_it.dart';
import 'package:writeit/data/repositories/draft_repository.dart';
import 'package:writeit/domain/repo/DraftRepositoryImpl.dart';
import '../../data/repositories/article_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/repo/ArticleRepositoryImpl.dart';
import '../../domain/repo/AuthRepositoryImpl.dart';

final getIt = GetIt.instance;

void setupLocator() {
  //Register Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<DraftRepository>(() => DraftRepositoryImpl());
  getIt.registerLazySingleton<ArticleRepository>(() => ArticleRepositoryImpl());
}
