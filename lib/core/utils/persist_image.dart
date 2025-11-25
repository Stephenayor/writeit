import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> persistImage(String originalPath) async {
  final docDir = await getApplicationDocumentsDirectory();
  final imagesDir = Directory("${docDir.path}/draft_images");

  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }

  // ALWAYS generate a new safe filename
  final newName = "draft_${DateTime.now().millisecondsSinceEpoch}.jpg";
  final newPath = "${imagesDir.path}/$newName";

  final originalFile = File(originalPath);

  // If the temp image is gone already → return empty path
  if (!await originalFile.exists()) {
    print("⚠️ Temp file no longer exists: $originalPath");
    return "";
  }

  final copiedFile = await originalFile.copy(newPath);
  return copiedFile.path;
}
