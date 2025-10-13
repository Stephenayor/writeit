import 'package:get_it/get_it.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/repo/AuthRepositoryImpl.dart';

final getIt = GetIt.instance;

void setupLocator() {
  //Register Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
}
