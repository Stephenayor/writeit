import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/app_user.dart';

class UserSessionHelper extends StateNotifier<AppUser?> {
  final FirebaseAuth _auth;

  UserSessionHelper(this._auth) : super(null) {
    _auth.userChanges().listen(_onUserChanged);
  }

  void _onUserChanged(User? firebaseUser) {
    if (firebaseUser == null) {
      state = null;
    } else {
      state = AppUser.fromFirebaseUser(firebaseUser);
    }
  }

  AppUser? get currentUser => state;

  Future<void> logout() async {
    await _auth.signOut();
    state = null;
  }
}
