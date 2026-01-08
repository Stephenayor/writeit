import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditorToolbar extends StatelessWidget {
  final VoidCallback onImage;
  final VoidCallback onHeading;
  final VoidCallback onQuote;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onBullet;
  final VoidCallback onNumbered;

  const EditorToolbar({
    required this.onImage,
    required this.onHeading,
    required this.onQuote,
    required this.onBold,
    required this.onItalic,
    required this.onBullet,
    required this.onNumbered,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              icon: const Text(
                'TT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: onHeading,
            ),
            IconButton(icon: const Icon(Icons.format_bold), onPressed: onBold),
            IconButton(
              icon: const Icon(Icons.format_italic),
              onPressed: onItalic,
            ),
            IconButton(
              icon: const Icon(Icons.format_quote),
              onPressed: onQuote,
            ),
            IconButton(
              icon: const Icon(Icons.format_list_bulleted),
              onPressed: onBullet,
            ),
            IconButton(
              icon: const Icon(Icons.format_list_numbered),
              onPressed: onNumbered,
            ),
            const Spacer(),
            IconButton(icon: const Icon(Icons.image), onPressed: onImage),
          ],
        ),
      ),
    );
  }
}
