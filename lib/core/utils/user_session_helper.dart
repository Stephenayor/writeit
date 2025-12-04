import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/app_user.dart';

class UserSessionHelper extends StateNotifier<AppUser?> {
  final FirebaseAuth _auth;
  StreamSubscription<User?>? _userSubscription;

  UserSessionHelper(this._auth) : super(null) {
    // _auth.userChanges().listen(_onUserChanged);
    _initialize();
  }

  void _initialize() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      state = AppUser.fromFirebaseUser(currentUser);
    }
    // Listen to auth state changes
    _userSubscription = _auth.userChanges().listen(_onUserChanged);
  }

  void _onUserChanged(User? firebaseUser) {
    if (firebaseUser == null) {
      state = null;
    } else {
      state = AppUser.fromFirebaseUser(firebaseUser);
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
    String? bio,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      if (displayName != null || photoURL != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        await user.reload();
      }

      // Update local state
      final updatedUser = _auth.currentUser;
      if (updatedUser != null) {
        state = AppUser.fromFirebaseUser(updatedUser).copyWith(bio: bio);
      }
    } catch (e) {
      rethrow;
    }
  }

  AppUser? get currentUser => state;

  Future<void> logout() async {
    await _auth.signOut();
    state = null;
  }
}
