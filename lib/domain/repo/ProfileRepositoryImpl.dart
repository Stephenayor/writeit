import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:writeit/core/utils/constants.dart';
import 'package:writeit/data/models/app_user.dart';
import 'package:writeit/data/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  ProfileRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _auth = auth ?? FirebaseAuth.instance;
  @override
  Future<AppUser> fetchUser() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore
        .collection(Constants.writeITUsersTable)
        .doc(uid)
        .get();
    return AppUser.fromJson(doc.data()!, uid);
  }

  @override
  Future<void> updateProfile({
    required String displayName,
    required String bio,
    File? newImage,
  }) async {
    final uid = _auth.currentUser!.uid;

    // Use UID for profile picture path (NEVER displayName!)
    final imageRef = _storage.ref(
      "profile_images/$uid${_auth.currentUser!.displayName}.jpg",
    );
    String? profileUrl;

    final currentName = _auth.currentUser!.displayName;
    if (displayName != currentName && displayName.isNotEmpty) {
      final taken = await isDisplayNameTaken(displayName);
      if (taken) throw Exception("User name already taken");
    }

    // Upload only when new image is selected
    if (newImage != null) {
      await imageRef.putFile(newImage);
      profileUrl = await imageRef.getDownloadURL();
    }

    // Update Firestore
    await _firestore.collection(Constants.writeITUsersTable).doc(uid).update({
      "name": displayName,
      "bio": bio,
      if (profileUrl != null) "photoUrl": profileUrl,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    // Update user's articles
    final articles = await _firestore
        .collection(Constants.articles)
        .where("authorId", isEqualTo: uid)
        .get();

    for (var doc in articles.docs) {
      await doc.reference.update({
        "authorName": displayName,
        if (profileUrl != null) "authorPhotoUrl": profileUrl,
      });
    }

    final firebaseUser = _auth.currentUser!;

    // Only update photo if a new one exists
    if (profileUrl != null) {
      await firebaseUser.updatePhotoURL(profileUrl);
    }

    // Only update name if changed
    if (displayName != currentName) {
      await firebaseUser.updateDisplayName(displayName);
    }

    await firebaseUser.reload();
  }

  Future<bool> isDisplayNameTaken(String displayName) async {
    final query = await _firestore
        .collection(Constants.writeITUsersTable)
        .where("name", isEqualTo: displayName)
        .get();

    return query.docs.isNotEmpty;
  }
}
