import 'package:writeit/core/utils/routes.dart';

String articleRoute(String id) {
  return Routes.articleById.replaceFirst(':id', id);
}
