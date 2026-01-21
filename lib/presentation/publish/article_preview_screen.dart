import 'dart:io';
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildContent(),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
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
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
                left: BorderSide(color: Colors.grey.shade400, width: 4),
              ),
              color: Colors.grey.shade50,
            ),
            child: Text(
              line.substring(2),
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(images[index]), fit: BoxFit.cover),
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
                const Text('• ', style: TextStyle(fontSize: 18)),
                Expanded(child: _parseInlineMarkdown(line.substring(2))),
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
                  style: const TextStyle(fontSize: 18),
                ),
                Expanded(child: _parseInlineMarkdown(text)),
              ],
            ),
          ),
        );
      }
      // Regular paragraph
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _parseInlineMarkdown(line),
          ),
        );
      }
    }

    return widgets;
  }

  // 1. Fix the italic markdown parsing in preview
  Widget _parseInlineMarkdown(String text) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|_(.+?)_|`(.+?)`');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      // Bold (**text**)
      if (match.group(1) != null) {
        spans.add(
          TextSpan(
            text: match.group(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
      // Italic (*text*) - single asterisk
      else if (match.group(2) != null) {
        spans.add(
          TextSpan(
            text: match.group(2),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      }
      // Italic underscore
      else if (match.group(3) != null) {
        spans.add(
          TextSpan(
            text: match.group(3),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      }
      // Code (inline)
      else if (match.group(4) != null) {
        spans.add(
          TextSpan(
            text: match.group(4),
            style: TextStyle(
              fontFamily: 'monospace',
              backgroundColor: Colors.grey.shade200,
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
        style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.black),
        children: spans.isEmpty ? [TextSpan(text: text)] : spans,
      ),
    );
  }
}
