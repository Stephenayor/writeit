import 'package:hive/hive.dart';
import 'package:writeit/data/models/draft.dart';
import '../../data/repositories/draft_repository.dart';

class DraftRepositoryImpl implements DraftRepository {
  final box = Hive.box('drafts_box');

  @override
  Future<void> deleteDraft(String id) async {
    await box.delete(id);
  }

  @override
  List<Draft> getAllDrafts() {
    return box.values
        .map((json) => Draft.fromJson(Map<String, dynamic>.from(json)))
        .toList()
        .reversed
        .toList();
  }

  @override
  Draft? getDraftById(String id) {
    final json = box.get(id);
    if (json == null) return null;
    return Draft.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<void> saveDraft(Draft draft) async {
    try {
      await box.put(draft.id, draft.toJson());
    } catch (e) {
      throw Exception("Failed to save draft");
    }
  }
}
