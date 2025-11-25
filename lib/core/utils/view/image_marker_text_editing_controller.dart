import 'package:flutter/material.dart';

class ImageMarkerTextEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final String displayText = text;
    final List<TextSpan> spans = [];

    // Split text and hide image markers
    final lines = displayText.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check if line contains image marker
      if (RegExp(r'^\[IMAGE:\d+\]$').hasMatch(line.trim())) {
        // Skip this line (don't display the marker)
        // Add just a newline
        if (i < lines.length - 1) {
          spans.add(TextSpan(text: '\n', style: style));
        }
      } else {
        // Regular line - display normally
        spans.add(TextSpan(text: line, style: style));

        // Add newline if not last line
        if (i < lines.length - 1) {
          spans.add(TextSpan(text: '\n', style: style));
        }
      }
    }

    return TextSpan(style: style, children: spans);
  }
}
