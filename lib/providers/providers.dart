import 'package:flutter_riverpod/legacy.dart';
import 'package:writeit/core/di/locator.dart';
import 'package:writeit/data/repositories/auth_repository.dart';
import '../domain/repo/AuthRepositoryImpl.dart';
import '../presentation/auth/signin/signin_state.dart';
import '../presentation/auth/signin/signinviewmodel.dart';
import '../presentation/auth/signup/signup_state.dart';
import '../presentation/auth/signup/signup_viewmodel.dart';

final signupViewModelProvider =
    StateNotifierProvider<SignupViewModel, SignupState>((ref) {
      final authRepo = getIt<AuthRepository>();
      return SignupViewModel(authRepo);
    });

final signinViewModelProvider =
    StateNotifierProvider<SigninViewModel, SigninState>((ref) {
      return SigninViewModel(AuthRepositoryImpl());
    });
