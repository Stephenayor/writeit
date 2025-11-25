import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';
import 'package:writeit/data/models/draft.dart';
import 'package:writeit/presentation/publish/drafts/draft_save_state.dart';
import '../../../data/repositories/draft_repository.dart';

class DraftsViewModel extends StateNotifier<DraftSaveState> {
  final DraftRepository _draftRepository;

  DraftsViewModel(this._draftRepository) : super(DraftSaveState.initial());

  Future<void> loadDrafts() async {
    try {
      final drafts = await _draftRepository.getAllDrafts();
      state = state.copyWith(draft: drafts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> saveDraft(Draft draft) async {
    try {
      state = state.copyWith(isSaving: true, error: null);

      await _draftRepository.saveDraft(draft);

      // Update list: replace if exists, otherwise add
      final updatedList = [...state.draft];
      final existingIndex = updatedList.indexWhere((d) => d.id == draft.id);

      if (existingIndex != -1) {
        updatedList[existingIndex] = draft;
      } else {
        updatedList.add(draft);
      }

      // when it succeeds, save drafts list
      state = state.copyWith(isSaving: false, draft: updatedList);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> deleteDraft(String id) async {
    try {
      //Removes saved images
      final draft = state.draft.firstWhere((d) => d.id == id);
      for (final path in draft.imagePaths) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }

      state = state.copyWith(isDeleting: true, error: null);
      await _draftRepository.deleteDraft(id);
      final updated = state.draft.where((d) => d.id != id).toList();
      state = state.copyWith(draft: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Future<void> deleteDraft(String id) async { await _draftRepository.deleteDraft(id); loadDrafts(); }

  Draft? getDraftById(String id) {
    return _draftRepository.getDraftById(id);
  }
}
