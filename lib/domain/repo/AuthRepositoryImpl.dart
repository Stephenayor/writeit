import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:writeit/core/utils/constants.dart';
import 'package:writeit/data/models/user_model.dart';
import 'package:writeit/data/repositories/auth_repository.dart';

import '../../presentation/auth/google_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  // final GoogleSignIn _googleSignIn;
  late User? _currentGoogleUser;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      late UserModel userModel;

      final user = userCredential.user;
      await user?.updateDisplayName(name);
      if (user != null) {
        userModel = UserModel(id: user.uid, name: name, email: email);
      }
      await _firestore
          .collection(Constants.writeITUsersTable)
          .doc(user?.uid)
          .set(userModel.toJson());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<UserModel> signUpWithGoogle() async {
    try {
      await GoogleSignInService.initSignIn();

      final UserCredential? userCredential =
          await GoogleSignInService.signInWithGoogle();

      if (userCredential == null || userCredential.user == null) {
        throw Exception('Google sign in cancelled or failed');
      }

      final User user = userCredential.user!;
      _currentGoogleUser = user;

      // Create UserModel from Firebase User
      final userModel = UserModel(
        id: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        createdAt: DateTime.now(),
      );

      // Check if user already exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // New user - create document
        await _firestore
            .collection(Constants.writeITUsersTable)
            .doc(user.uid)
            .set(userModel.toJson());

        return userModel;
      } else {
        return UserModel.fromJson(userDoc.data()!);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Google sign in failed';

      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'Account already exists with different credentials';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid credentials provided';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google sign in is not enabled';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled';
          break;
        default:
          errorMessage = e.message ?? 'Google sign in failed';
      }

      throw Exception(errorMessage);
    } catch (e) {
      // Handle other errors
      print('Error in signUpWithGoogle: $e');
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );
      final user = userCredential.user!;

      final userModel = UserModel(
        id: user.uid,
        name: appleCredential.givenName ?? user.displayName ?? '',
        email: appleCredential.email ?? user.email ?? '',
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson(), SetOptions(merge: true));

      return userModel;
    } catch (e) {
      throw Exception('Apple sign in failed: $e');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'An error occurred. Please try again';
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google first
      if (GoogleSignInService.getCurrentUser() != null) {
        await GoogleSignInService.signOut();
      }
      // Then sign out from Firebase
      await _firebaseAuth.signOut();
      if (kDebugMode) {
        print('Signed out completely from both Google and Firebase');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during complete sign out: $e');
      }
      throw e;
    }
  }

  User? getCurrentUser() {
    return GoogleSignInService.getCurrentUser();
  }

  @override
  Future<UserModel?> getCurrentUserModel() async {
    try {
      final user = getCurrentUser();
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) return null;

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting current user model: $e');
      return null;
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  @override
  Stream<UserModel?> userModelStream() {
    return authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) return null;

      return UserModel.fromJson(doc.data()!);
    });
  }
}
