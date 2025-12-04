import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String? displayName;
  final String? photoURL;
  final String? email;
  final String? phoneNumber;
  final String? bio;

  AppUser({
    required this.uid,
    this.displayName,
    this.photoURL,
    this.email,
    this.phoneNumber,
    this.bio,
  });

  factory AppUser.fromFirebaseUser(User firebaseUser) {
    return AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
    );
  }

  AppUser copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    String? bio,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
    );
  }
}
