import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class ImagePersistenceHelper {
  // Get the permanent images directory
  static Future<Directory> getImagesDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory imagesDir = Directory('${appDir.path}/article_images');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir;
  }

  // Copy image from temporary location to permanent app storage
  // Returns just the filename (not full path)
  static Future<String> persistImage(String sourcePath) async {
    try {
      final File sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        if (kDebugMode) {
          print('Source image does not exist: $sourcePath');
        }
        return '';
      }

      final Directory imagesDir = await getImagesDirectory();

      // Generate unique filename using timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(sourcePath);
      final String fileName = 'article_image_$timestamp$extension';
      final String destinationPath = '${imagesDir.path}/$fileName';

      // Copy file to permanent storage
      await sourceFile.copy(destinationPath);

      if (kDebugMode) {
        print('Image persisted: $fileName');
      }

      // Return ONLY the filename, not the full path
      return fileName;
    } catch (e) {
      if (kDebugMode) {
        print('Error persisting image: $e');
      }
      return '';
    }
  }

  // Get full path from filename
  static Future<String> getFullPath(String filename) async {
    try {
      final Directory imagesDir = await getImagesDirectory();
      return '${imagesDir.path}/$filename';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting full path: $e');
      }
      return '';
    }
  }

  // Check if image exists by filename
  static Future<bool> imageExists(String filename) async {
    try {
      // If it's already a full path, extract filename
      String actualFilename = filename;
      if (filename.contains('/')) {
        actualFilename = path.basename(filename);
      }

      final Directory imagesDir = await getImagesDirectory();
      final File file = File('${imagesDir.path}/$actualFilename');
      final exists = await file.exists();

      if (kDebugMode) {
        print('Checking image: $actualFilename - Exists: $exists');
      }

      return exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking image existence: $e');
      }
      return false;
    }
  }

  // Get File object from filename
  static Future<File?> getImageFile(String filename) async {
    try {
      // If it's already a full path, extract filename
      String actualFilename = filename;
      if (filename.contains('/')) {
        actualFilename = path.basename(filename);
      }

      final Directory imagesDir = await getImagesDirectory();
      final File file = File('${imagesDir.path}/$actualFilename');

      if (await file.exists()) {
        return file;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting image file: $e');
      }
      return null;
    }
  }

  // Clean up old draft images that are no longer referenced
  static Future<void> cleanupUnusedImages(
    List<String> referencedFilenames,
  ) async {
    try {
      final Directory imagesDir = await getImagesDirectory();

      if (!await imagesDir.exists()) return;

      final List<FileSystemEntity> files = imagesDir.listSync();

      // Extract just filenames from referenced list
      final Set<String> referencedNames = referencedFilenames
          .map((f) => f.contains('/') ? path.basename(f) : f)
          .toSet();

      for (final file in files) {
        if (file is File) {
          final String filename = path.basename(file.path);

          // If this image is not referenced by any draft, delete it
          if (!referencedNames.contains(filename)) {
            await file.delete();
            if (kDebugMode) {
              print('Deleted unused image: $filename');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up images: $e');
      }
    }
  }

  // Delete specific image by filename
  static Future<void> deleteImage(String filename) async {
    try {
      // If it's a full path, extract filename
      String actualFilename = filename;
      if (filename.contains('/')) {
        actualFilename = path.basename(filename);
      }

      final Directory imagesDir = await getImagesDirectory();
      final File file = File('${imagesDir.path}/$actualFilename');

      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print('Deleted image: $actualFilename');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
    }
  }

  // Convert old full paths to filenames (migration helper)
  static String extractFilename(String pathOrFilename) {
    if (pathOrFilename.contains('/')) {
      return path.basename(pathOrFilename);
    }
    return pathOrFilename;
  }

  // Validate and fix image paths in a list
  static Future<List<String>> validateImagePaths(List<String> paths) async {
    final validPaths = <String>[];

    for (final imagePath in paths) {
      final filename = extractFilename(imagePath);
      if (await imageExists(filename)) {
        validPaths.add(filename);
      } else {
        if (kDebugMode) {
          print('Invalid image path removed: $imagePath');
        }
      }
    }

    return validPaths;
  }
}
