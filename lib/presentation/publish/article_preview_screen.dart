import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/utils/helper/image_persistence_helper.dart';

class ArticlePreviewScreen extends StatelessWidget {
  final String content;
  final List<String> images;

  const ArticlePreviewScreen({
    super.key,
    required this.content,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text('Preview'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildContent(isDark),
        ),
      ),
    );
  }

  List<Widget> _buildContent(bool isDark) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Heading
      if (line.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 8),
            child: Text(
              line.substring(2),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }
      // Quote
      else if (line.startsWith('> ')) {
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 16, top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                  width: 4,
                ),
              ),
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
            ),
            child: Text(
              line.substring(2),
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey[400] : Colors.grey,
              ),
            ),
          ),
        );
      }
      // Image placeholder
      else if (line.startsWith('[IMAGE:')) {
        final match = RegExp(r'\[IMAGE:(\d+)\]').firstMatch(line);
        if (match != null) {
          final index = int.parse(match.group(1)!);
          if (index < images.length) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: FutureBuilder<File?>(
                  future: ImagePersistenceHelper.getImageFile(images[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError || snapshot.data == null) {
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image not found',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.error,
                                size: 48,
                                color: Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          }
        }
      }
      // Bullet list
      else if (line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Expanded(
                  child: _parseInlineMarkdown(line.substring(2), isDark),
                ),
              ],
            ),
          ),
        );
      }
      // Numbered list
      else if (RegExp(r'^\d+\. ').hasMatch(line)) {
        final text = line.replaceFirst(RegExp(r'^\d+\. '), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${line.split('.')[0]}. ',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Expanded(child: _parseInlineMarkdown(text, isDark)),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _parseInlineMarkdown(line, isDark),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _parseInlineMarkdown(String text, bool isDark) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|_(.+?)_|`(.+?)`');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      if (match.group(1) != null) {
        spans.add(
          TextSpan(
            text: match.group(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (match.group(2) != null) {
        spans.add(
          TextSpan(
            text: match.group(2),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      } else if (match.group(3) != null) {
        spans.add(
          TextSpan(
            text: match.group(3),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      } else if (match.group(4) != null) {
        spans.add(
          TextSpan(
            text: match.group(4),
            style: TextStyle(
              fontFamily: 'monospace',
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
            ),
          ),
        );
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 18,
          height: 1.6,
          color: isDark ? Colors.white : Colors.black,
        ),
        children: spans.isEmpty ? [TextSpan(text: text)] : spans,
      ),
    );
  }
}
