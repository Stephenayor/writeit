import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:writeit/data/models/app_user.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileViewModel extends StateNotifier<AsyncValue<AppUser>> {
  final ProfileRepository _repo;

  ProfileViewModel(this._repo) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.fetchUser();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateProfile({
    required String name,
    required String bio,
    File? image,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _repo.updateProfile(displayName: name, bio: bio, newImage: image);

      final updated = await _repo.fetchUser();
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st); //failure
    }
  }
}
