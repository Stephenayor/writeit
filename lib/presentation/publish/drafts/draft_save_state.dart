import 'package:writeit/data/models/draft.dart';

class DraftSaveState {
  final bool isSaving;
  final List<Draft> draft;
  final String? error;

  const DraftSaveState({
    this.isSaving = false,
    required this.draft,
    this.error,
  });

  DraftSaveState copyWith({bool? isSaving, List<Draft>? draft, String? error}) {
    return DraftSaveState(
      isSaving: isSaving ?? this.isSaving,
      draft: draft ?? this.draft,
      error: error,
    );
  }

  static DraftSaveState initial() => const DraftSaveState(draft: []);
}
