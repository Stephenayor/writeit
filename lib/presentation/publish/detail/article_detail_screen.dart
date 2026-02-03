import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/constants.dart';
import '../../../data/models/article.dart';
import '../../../providers/providers.dart';
import '../../comments/article_comment_composer.dart';
import '../../comments/comments_sheet.dart';
import 'article_pdf_service.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final currentUserName = user?.displayName;
    final currentUserAvatar = user?.photoURL;
    final commentsCount = article.commentsCount;
    final commentsRepository = ref.read(commentRepositoryProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.blueGrey,
        title: Text(
          article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          StreamBuilder<bool>(
            stream: FirebaseFirestore.instance
                .collection(Constants.articles)
                .doc(article.id)
                .collection(Constants.likes)
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots()
                .map((doc) => doc.exists),
            builder: (context, snapshot) {
              final isLiked = snapshot.data ?? false;

              return IconButton(
                onPressed: () {
                  commentsRepository.toggleLike(
                    article.id,
                    FirebaseAuth.instance.currentUser!.uid,
                  );
                },
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey,
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => showComments(context, article.id),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.comment_outlined, size: 26),
                  ),

                  if (commentsCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 18),
                        child: Text(
                          commentsCount > 99 ? "99+" : commentsCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final file = await ArticlePdfService.generatePdf(article);

              await Share.shareXFiles([
                XFile(file.path),
              ], subject: article.title);
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // ARTICLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: MarkdownBody(
                data: article.content,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                    .copyWith(
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

                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  )) {
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
          ),

          // COMMENT COMPOSER
          ArticleCommentComposer(
            avatarUrl: currentUserAvatar ?? "Guest",
            username: currentUserName ?? "",
            onTap: () => showComments(context, article.id),
          ),
        ],
      ),
    );
  }

  void showComments(BuildContext context, String articleId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CommentsSheet(articleId: articleId),
    );
  }
}
