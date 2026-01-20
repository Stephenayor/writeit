import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/constants.dart';
import '../../data/models/article.dart';
import '../../data/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final FirebaseFirestore firestore;

  SearchRepositoryImpl(this.firestore);

  @override
  Future<List<Article>> searchArticles(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final snap = await firestore
        .collection(Constants.articles)
        .orderBy('titleLower')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .limit(20)
        .get();

    return snap.docs.map((e) => Article.fromJson(e.data(), e.id)).toList();
  }
}
