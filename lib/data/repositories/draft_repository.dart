import 'package:writeit/data/models/draft.dart';

abstract class DraftRepository {
  Future<void> saveDraft(Draft draft);
  Future<void> deleteDraft(String id);
  List<Draft> getAllDrafts();
  Draft? getDraftById(String id);
}
