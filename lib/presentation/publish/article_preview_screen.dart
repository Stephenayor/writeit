// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// // class ArticlePreviewScreen extends StatelessWidget {
// //   final String content;
// //   final List<String> images;
// //
// //   const ArticlePreviewScreen({
// //     Key? key,
// //     required this.content,
// //     required this.images,
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final isDark = Theme.of(context).brightness == Brightness.dark;
// //
// //     return Scaffold(
// //       backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: Icon(
// //             Icons.close,
// //             color: isDark ? Colors.white : Colors.black87,
// //           ),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: Text(
// //           'Preview',
// //           style: TextStyle(color: isDark ? Colors.white : Colors.black87),
// //         ),
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(20),
// //         child: _buildPreviewContent(content, images, isDark),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildPreviewContent(
// //     String content,
// //     List<String> images,
// //     bool isDark,
// //   ) {
// //     final lines = content.split('\n');
// //     final widgets = <Widget>[];
// //
// //     for (final line in lines) {
// //       // Check for image marker
// //       final imageMatch = RegExp(r'\[IMAGE:(\d+)\]').firstMatch(line);
// //
// //       if (imageMatch != null) {
// //         final imageIndex = int.parse(imageMatch.group(1)!);
// //         if (imageIndex < images.length) {
// //           widgets.add(
// //             Container(
// //               margin: const EdgeInsets.symmetric(vertical: 12),
// //               child: ClipRRect(
// //                 borderRadius: BorderRadius.circular(8),
// //                 child: Image.file(
// //                   File(images[imageIndex]),
// //                   fit: BoxFit.cover,
// //                   width: double.infinity,
// //                 ),
// //               ),
// //             ),
// //           );
// //         }
// //       } else if (line.trim().isNotEmpty) {
// //         // Render text based on markdown
// //         widgets.add(_buildTextLine(line, isDark));
// //       }
// //     }
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: widgets,
// //     );
// //   }
// //
// //   Widget _buildTextLine(String line, bool isDark) {
// //     final trimmed = line.trim();
// //
// //     // Bold heading
// //     if (trimmed.startsWith('**') && trimmed.endsWith('**')) {
// //       final text = trimmed.substring(2, trimmed.length - 2);
// //       return Padding(
// //         padding: const EdgeInsets.only(bottom: 16),
// //         child: Text(
// //           text,
// //           style: TextStyle(
// //             fontSize: 28,
// //             fontWeight: FontWeight.bold,
// //             color: isDark ? Colors.white : Colors.black87,
// //           ),
// //         ),
// //       );
// //     }
// //
// //     // Quote
// //     if (trimmed.startsWith('>')) {
// //       final text = trimmed.substring(1).trim();
// //       return Container(
// //         margin: const EdgeInsets.only(bottom: 12),
// //         padding: const EdgeInsets.only(left: 16),
// //         decoration: BoxDecoration(
// //           border: Border(
// //             left: BorderSide(
// //               color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
// //               width: 4,
// //             ),
// //           ),
// //         ),
// //         child: Text(
// //           text,
// //           style: TextStyle(
// //             fontSize: 18,
// //             fontStyle: FontStyle.italic,
// //             color: isDark ? Colors.grey[400] : Colors.grey[700],
// //           ),
// //         ),
// //       );
// //     }
// //
// //     // Bullet
// //     if (trimmed.startsWith('•')) {
// //       final text = trimmed.substring(1).trim();
// //       return Padding(
// //         padding: const EdgeInsets.only(bottom: 8),
// //         child: Row(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Text('• ', style: TextStyle(fontSize: 18)),
// //             Expanded(
// //               child: Text(
// //                 text,
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                   color: isDark ? Colors.white : Colors.black87,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
// //
// //     // Numbered list
// //     final numberMatch = RegExp(r'^(\d+)\.\s').firstMatch(trimmed);
// //     if (numberMatch != null) {
// //       final number = numberMatch.group(1);
// //       final text = trimmed.substring(numberMatch.group(0)!.length);
// //       return Padding(
// //         padding: const EdgeInsets.only(bottom: 8),
// //         child: Row(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             SizedBox(
// //               width: 30,
// //               child: Text(
// //                 '$number. ',
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                   color: isDark ? Colors.white : Colors.black87,
// //                 ),
// //               ),
// //             ),
// //             Expanded(
// //               child: Text(
// //                 text,
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                   color: isDark ? Colors.white : Colors.black87,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
// //
// //     // Divider
// //     if (trimmed == '• • •') {
// //       return Container(
// //         margin: const EdgeInsets.symmetric(vertical: 20),
// //         child: Center(
// //           child: Text(
// //             '• • •',
// //             style: TextStyle(
// //               fontSize: 24,
// //               color: isDark ? Colors.grey[600] : Colors.grey[400],
// //             ),
// //           ),
// //         ),
// //       );
// //     }
// //
// //     // Regular paragraph with inline formatting
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 12),
// //       child: _buildFormattedText(trimmed, isDark),
// //     );
// //   }
// //
// //   Widget _buildFormattedText(String text, bool isDark) {
// //     final spans = <TextSpan>[];
// //     var remaining = text;
// //
// //     while (remaining.isNotEmpty) {
// //       // Bold: **text**
// //       final boldMatch = RegExp(r'\*\*([^*]+)\*\*').firstMatch(remaining);
// //       if (boldMatch != null && boldMatch.start == 0) {
// //         spans.add(
// //           TextSpan(
// //             text: boldMatch.group(1),
// //             style: const TextStyle(fontWeight: FontWeight.bold),
// //           ),
// //         );
// //         remaining = remaining.substring(boldMatch.end);
// //         continue;
// //       }
// //
// //       // Italic: *text*
// //       final italicMatch = RegExp(r'\*([^*]+)\*').firstMatch(remaining);
// //       if (italicMatch != null && italicMatch.start == 0) {
// //         spans.add(
// //           TextSpan(
// //             text: italicMatch.group(1),
// //             style: const TextStyle(fontStyle: FontStyle.italic),
// //           ),
// //         );
// //         remaining = remaining.substring(italicMatch.end);
// //         continue;
// //       }
// //
// //       // Link: [text](url)
// //       final linkMatch = RegExp(
// //         r'\[([^\]]+)\]\(([^)]+)\)',
// //       ).firstMatch(remaining);
// //       if (linkMatch != null && linkMatch.start == 0) {
// //         spans.add(
// //           TextSpan(
// //             text: linkMatch.group(1),
// //             style: const TextStyle(
// //               color: Colors.blue,
// //               decoration: TextDecoration.underline,
// //             ),
// //           ),
// //         );
// //         remaining = remaining.substring(linkMatch.end);
// //         continue;
// //       }
// //
// //       // Regular text until next special character
// //       final nextSpecial = RegExp(r'[\*\[]').firstMatch(remaining);
// //       if (nextSpecial != null) {
// //         spans.add(TextSpan(text: remaining.substring(0, nextSpecial.start)));
// //         remaining = remaining.substring(nextSpecial.start);
// //       } else {
// //         spans.add(TextSpan(text: remaining));
// //         break;
// //       }
// //     }
// //
// //     return RichText(
// //       text: TextSpan(
// //         style: TextStyle(
// //           fontSize: 18,
// //           height: 1.6,
// //           color: isDark ? Colors.white : Colors.black87,
// //         ),
// //         children: spans,
// //       ),
// //     );
// //   }
// // }
//
// import 'dart:io';
// import 'package:flutter/material.dart';
//
// class ArticlePreviewScreen extends StatelessWidget {
//   final String content;
//   final List<String> images;
//
//   const ArticlePreviewScreen({
//     super.key,
//     required this.content,
//     required this.images,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Preview'),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: _buildContent(),
//         ),
//       ),
//     );
//   }
//
//   List<Widget> _buildContent() {
//     final lines = content.split('\n');
//     final widgets = <Widget>[];
//
//     for (final line in lines) {
//       if (line.trim().isEmpty) {
//         widgets.add(const SizedBox(height: 8));
//         continue;
//       }
//
//       // Heading
//       if (line.startsWith('# ')) {
//         widgets.add(
//           Padding(
//             padding: const EdgeInsets.only(bottom: 16, top: 8),
//             child: Text(
//               line.substring(2),
//               style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//             ),
//           ),
//         );
//       }
//       // Quote
//       else if (line.startsWith('> ')) {
//         widgets.add(
//           Container(
//             margin: const EdgeInsets.only(bottom: 16, top: 8),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               border: Border(
//                 left: BorderSide(color: Colors.grey.shade400, width: 4),
//               ),
//               color: Colors.grey.shade50,
//             ),
//             child: Text(
//               line.substring(2),
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontStyle: FontStyle.italic,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//         );
//       }
//       // Image placeholder
//       else if (line.startsWith('[IMAGE:')) {
//         final match = RegExp(r'\[IMAGE:(\d+)\]').firstMatch(line);
//         if (match != null) {
//           final index = int.parse(match.group(1)!);
//           if (index < images.length) {
//             widgets.add(
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.file(File(images[index]), fit: BoxFit.cover),
//                 ),
//               ),
//             );
//           }
//         }
//       }
//       // Bullet list
//       else if (line.startsWith('- ')) {
//         widgets.add(
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8, left: 16),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text('• ', style: TextStyle(fontSize: 18)),
//                 Expanded(child: _parseInlineMarkdown(line.substring(2))),
//               ],
//             ),
//           ),
//         );
//       }
//       // Numbered list
//       else if (RegExp(r'^\d+\. ').hasMatch(line)) {
//         final text = line.replaceFirst(RegExp(r'^\d+\. '), '');
//         widgets.add(
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8, left: 16),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${line.split('.')[0]}. ',
//                   style: const TextStyle(fontSize: 18),
//                 ),
//                 Expanded(child: _parseInlineMarkdown(text)),
//               ],
//             ),
//           ),
//         );
//       }
//       // Regular paragraph
//       else {
//         widgets.add(
//           Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: _parseInlineMarkdown(line),
//           ),
//         );
//       }
//     }
//
//     return widgets;
//   }
//
//   Widget _parseInlineMarkdown(String text) {
//     final spans = <InlineSpan>[];
//     final regex = RegExp(r'\*\*(.+?)\*\*|_(.+?)_|`(.+?)`');
//     int lastIndex = 0;
//
//     for (final match in regex.allMatches(text)) {
//       // Add text before the match
//       if (match.start > lastIndex) {
//         spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
//       }
//
//       // Bold
//       if (match.group(1) != null) {
//         spans.add(
//           TextSpan(
//             text: match.group(1),
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         );
//       }
//       // Italic
//       else if (match.group(2) != null) {
//         spans.add(
//           TextSpan(
//             text: match.group(2),
//             style: const TextStyle(fontStyle: FontStyle.italic),
//           ),
//         );
//       }
//       // Code (inline)
//       else if (match.group(3) != null) {
//         spans.add(
//           TextSpan(
//             text: match.group(3),
//             style: TextStyle(
//               fontFamily: 'monospace',
//               backgroundColor: Colors.grey.shade200,
//             ),
//           ),
//         );
//       }
//
//       lastIndex = match.end;
//     }
//
//     // Add remaining text
//     if (lastIndex < text.length) {
//       spans.add(TextSpan(text: text.substring(lastIndex)));
//     }
//
//     return RichText(
//       text: TextSpan(
//         style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.black),
//         children: spans.isEmpty ? [TextSpan(text: text)] : spans,
//       ),
//     );
//   }
// }

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
