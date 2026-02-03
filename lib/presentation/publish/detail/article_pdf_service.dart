import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:markdown/markdown.dart' as md;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../../../data/models/article.dart';

class ArticlePdfService {
  static Future<File> generatePdf(Article article) async {
    final pdf = pw.Document();
    final markdownNodes = md.Document().parseLines(article.content.split('\n'));
    final contentWidgets = await renderMarkdown(
      markdown: article.content,
      authorName: article.authorName,
      publishDate: article.createdAt!.toDate(),
    );

    pdf.addPage(pw.MultiPage(build: (_) => contentWidgets));

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/${article.title}.pdf");
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<List<pw.Widget>> renderMarkdown({
    required String markdown,
    required String authorName,
    required DateTime publishDate,
  }) async {
    final widgets = <pw.Widget>[];

    widgets.addAll([
      pw.Text(
        'By $authorName',
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey800,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        _formatDate(publishDate),
        style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
      ),
      pw.SizedBox(height: 12),
      pw.Divider(color: PdfColors.grey400),
      pw.SizedBox(height: 16),
    ]);

    final lines = markdown.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.startsWith('![')) {
        final match = RegExp(r'!\[.*?\]\((.*?)\)').firstMatch(trimmed);
        if (match != null) {
          final imageUrl = match.group(1)!;
          final image = await _loadNetworkImage(imageUrl);

          if (image != null) {
            widgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 12),
                child: pw.ClipRRect(
                  horizontalRadius: 8,
                  verticalRadius: 8,
                  child: pw.Image(image),
                ),
              ),
            );
          }
        }
        continue;
      }

      if (trimmed.startsWith('# ')) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Text(
              trimmed.replaceFirst('# ', ''),
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('- ')) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Bullet(
              text: trimmed.replaceFirst('- ', ''),
              style: const pw.TextStyle(fontSize: 14),
            ),
          ),
        );
        continue;
      }

      if (trimmed.isNotEmpty) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Text(
              trimmed,
              style: const pw.TextStyle(fontSize: 14, lineSpacing: 4),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  static Future<Uint8List> _loadImage(String url) async {
    final res = await http.get(Uri.parse(url));
    return res.bodyBytes;
  }

  static Future<pw.MemoryImage?> _loadNetworkImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } catch (_) {}
    return null;
  }

  static String _formatDate(DateTime date) {
    return '${_month(date.month)} ${date.day}, ${date.year}';
  }

  static String _month(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }
}
