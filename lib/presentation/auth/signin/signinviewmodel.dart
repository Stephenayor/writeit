import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:writeit/data/repositories/auth_repository.dart';
import 'package:writeit/presentation/auth/signin/signin_state.dart';

class SigninViewModel extends StateNotifier<SigninState> {
  final AuthRepository _authRepository;

  SigninViewModel(this._authRepository) : super(SigninState());

  void updateEmail(String email) {
    state = state.copyWith(email: email, errorMessage: null);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password, errorMessage: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  Future<bool> signInWithEmail() async {
    if (!_validateInputs()) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: state.email,
        password: state.password,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _handleAuthException(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred. Please try again',
      );
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  bool _validateInputs() {
    if (state.email.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email');
      return false;
    }

    if (!_isValidEmail(state.email)) {
      state = state.copyWith(errorMessage: 'Please enter a valid email');
      return false;
    }

    if (state.password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your password');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Sign in failed. Please try again';
    }
  }
}
