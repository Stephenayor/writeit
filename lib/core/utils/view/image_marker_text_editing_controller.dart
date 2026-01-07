import 'dart:io';
import 'package:flutter/material.dart';
import 'package:writeit/core/utils/helper/image_persistence_helper.dart';

class ImageMarkerTextEditingController extends TextEditingController {
  final List<String> images;
  final Map<int, File?> imageCache = {};
  final Function(int)? onImageRemove;

  ImageMarkerTextEditingController({
    required this.images,
    String? text,
    this.onImageRemove,
  }) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> spans = [];
    final text = this.text;

    // Split text by lines to handle image markers
    final lines = text.split('\n');

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];

      // Check if this line is an image marker
      final imageMatch = RegExp(r'^\[IMAGE:(\d+)\]$').firstMatch(line.trim());

      if (imageMatch != null) {
        final imageIndex = int.parse(imageMatch.group(1)!);

        if (imageIndex < images.length) {
          // Add the image as a widget span
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _buildImageWidget(context, imageIndex),
            ),
          );
        } else {
          // Invalid image index, show as text
          spans.add(TextSpan(text: line, style: style));
        }
      } else {
        // Regular text line
        spans.add(TextSpan(text: line, style: style));
      }

      // Add newline between lines (except for the last line)
      if (lineIndex < lines.length - 1) {
        spans.add(TextSpan(text: '\n', style: style));
      }
    }

    return TextSpan(style: style, children: spans);
  }

  Widget _buildImageWidget(BuildContext context, int index) {
    final cachedFile = imageCache[index];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Load image if not in cache
    if (cachedFile == null) {
      _loadImageToCache(index);

      return Container(
        width: double.infinity,
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width - 40, // Account for padding
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              cachedFile,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          if (onImageRemove != null)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => onImageRemove!(index),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadImageToCache(int index) async {
    if (index >= images.length) return;

    final file = await ImagePersistenceHelper.getImageFile(images[index]);
    if (file != null) {
      imageCache[index] = file;
      notifyListeners(); // Trigger rebuild to show loaded image
    }
  }

  // Preload all images
  Future<void> preloadImages() async {
    for (int i = 0; i < images.length; i++) {
      await _loadImageToCache(i);
    }
  }
}
