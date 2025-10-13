import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isInitialize = false;
  static Future<void> initSignIn() async {
    if (!isInitialize) {
      await _googleSignIn.initialize(
        serverClientId:
            '598164158629-oe280kcntj8jfd1p9bhpds039kmb6fh8.apps.googleusercontent.com',
      );
    }
    isInitialize = true;
  }

  // Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      initSignIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;
      GoogleSignInClientAuthorization? authorization = await authorizationClient
          .authorizationForScopes(['email', 'profile']);
      final accessToken = authorization?.accessToken;
      if (accessToken == null) {
        final authorization2 = await authorizationClient.authorizationForScopes(
          ['email', 'profile'],
        );
        if (authorization2?.accessToken == null) {
          throw FirebaseAuthException(code: "error", message: "error");
        }
        authorization = authorization2;
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;
      // if (user != null) {
      //   final userDoc = FirebaseFirestore.instance
      //       .collection('users')
      //       .doc(user.uid);
      //   final docSnapshot = await userDoc.get();
      //   if (!docSnapshot.exists) {
      //     await userDoc.set({
      //       'uid': user.uid,
      //       'name': user.displayName ?? '',
      //       'email': user.email ?? '',
      //       'photoURL': user.photoURL ?? '',
      //       'provider': 'google',
      //       'createdAt': FieldValue.serverTimestamp(),
      //     });
      //   }
      // }
      return userCredential;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// class GoogleAuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   Future<User?> signInWithGoogle() async {
//     try {
//       final googleUser = await _googleSignIn.signIn();
//
//       if (googleUser == null) return null;
//
//       // Retrieve the authentication details from the Google account.
//       final googleAuth = await googleUser.authentication;
//
//       // Create a new credential using the Google authentication details.
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       final userCredential = await _auth.signInWithCredential(credential);
//
//       return userCredential.user;
//     } catch (e) {
//       if (kDebugMode) {
//         print("Sign-in error: $e");
//       }
//       return null;
//     }
//   }
//
//   Future<void> signOut() async {
//     // Sign out from Google.
//     await _googleSignIn.signOut();
//
//     // Sign out from Firebase.
//     await _auth.signOut();
//   }
// }
