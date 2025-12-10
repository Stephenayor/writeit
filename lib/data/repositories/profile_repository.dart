import 'dart:io';

import 'package:writeit/data/models/app_user.dart';

abstract class ProfileRepository {
  Future<AppUser> fetchUser();
  Future<void> updateProfile({
    required String displayName,
    required String bio,
    File? newImage,
  });
}
