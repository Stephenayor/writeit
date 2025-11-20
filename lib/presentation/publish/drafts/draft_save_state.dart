import '../../../data/models/draft.dart';

class DraftSaveState {
  final bool isSaving;
  final bool isDeleting;
  final String? error;
  final List<Draft> draft;

  const DraftSaveState({
    this.isSaving = false,
    this.isDeleting = false,
    required this.draft,
    this.error,
  });

  DraftSaveState copyWith({
    bool? isSaving,
    bool? isDeleting,
    List<Draft>? draft,
    String? error,
  }) {
    return DraftSaveState(
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      draft: draft ?? this.draft,
      error: error,
    );
  }

  static DraftSaveState initial() => const DraftSaveState(draft: []);
}
