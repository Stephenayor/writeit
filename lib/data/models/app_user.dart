import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  AppUser({required this.uid, this.displayName, this.email, this.photoUrl});

  factory AppUser.fromFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
    );
  }
}
