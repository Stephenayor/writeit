import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:writeit/presentation/auth/signup/signup_state.dart';
import '../../../data/repositories/auth_repository.dart';

class SignupViewModel extends StateNotifier<SignupState> {
  final AuthRepository _authRepository;

  SignupViewModel(this._authRepository) : super(SignupState());

  void updateName(String name) {
    state = state.copyWith(name: name, errorMessage: null);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, errorMessage: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  Future<bool> signUpWithEmail() async {
    if (!_validateInputs()) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.signUpWithEmail(
        name: state.name,
        email: state.email,
        password: state.password,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.signUpWithGoogle();
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.signInWithApple();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  bool _validateInputs() {
    if (state.name.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your name');
      return false;
    }

    if (state.email.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email');
      return false;
    }

    if (!_isValidEmail(state.email)) {
      state = state.copyWith(errorMessage: 'Please enter a valid email');
      return false;
    }

    if (state.password.length < 8) {
      state = state.copyWith(
        errorMessage: 'Password must be at least 8 characters',
      );
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  User? get currentUser => FirebaseAuth.instance.currentUser;
}

// Provider
// final authRepositoryProvider = Provider<AuthRepository>((ref) {
//   return AuthRepositoryImpl();
// });

// final signupViewModelProvider =
//     StateNotifierProvider<SignupViewModel, SignupState>((ref) {
//       return SignupViewModel(ref.read(authRepositoryProvider));
//     });
