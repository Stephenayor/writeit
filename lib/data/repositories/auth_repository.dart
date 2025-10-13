import 'package:firebase_auth/firebase_auth.dart';
import 'package:writeit/data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithGoogle();
  Future<UserModel> signInWithApple();
  Future<void> signOut();
  // Future<User?> getCurrentUser();
  Future<UserModel?> getCurrentUserModel();
  Stream<User?> authStateChanges();
  Stream<UserModel?> userModelStream();
}
