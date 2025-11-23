// import 'package:extended_text_field/extended_text_field.dart';
// import 'package:flutter/cupertino.dart';
//
// class MyMarkdownStyleBuilder extends SpecialTextSpanBuilder {
//   @override
//   TextSpan build(String data, {TextStyle? textStyle, onTap}) {
//     return TextSpan(children: _parseMarkdown(data, textStyle));
//   }
//
//   List<InlineSpan> _parseMarkdown(String text, TextStyle? baseStyle) {
//     final spans = <InlineSpan>[];
//
//     final boldRegex = RegExp(r'\*\*(.+?)\*\*');
//     final italicRegex = RegExp(r'\*(.+?)\*');
//     final quoteRegex = RegExp(r'(> .*)');
//
//     text.splitMapJoin(
//       boldRegex,
//       onMatch: (m) {
//         spans.add(
//           TextSpan(
//             text: m.group(1),
//             style: baseStyle?.copyWith(fontWeight: FontWeight.w700),
//           ),
//         );
//         return '';
//       },
//       onNonMatch: (str) {
//         // handle italics, quote similarly or fallback
//         spans.add(TextSpan(text: str, style: baseStyle));
//         return '';
//       },
//     );
//
//     return spans;
//   }
//
//   @override
//   SpecialText? createSpecialText(
//     String flag, {
//     TextStyle? textStyle,
//     SpecialTextGestureTapCallback? onTap,
//     required int index,
//   }) {
//     // TODO: implement createSpecialText
//     throw UnimplementedError();
//   }
// }
