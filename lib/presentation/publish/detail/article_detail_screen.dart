import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/article.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MarkdownBody(
          data: article.content,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onTapLink: (text, href, title) async {
            if (href == null) return;
            final uri = Uri.tryParse(href);
            if (uri == null) return;

            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              // Optional: show a toast / snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not open link')),
              );
            }
          },
          imageBuilder: (uri, title, alt) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  uri.toString(),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
