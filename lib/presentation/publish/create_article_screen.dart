import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/network/api_response.dart';
import '../../core/utils/helper/image_persistence_helper.dart';
import '../../core/utils/routes.dart';
import '../../data/models/draft.dart';
import '../../providers/providers.dart';
import 'article_preview_screen.dart';
import 'editor_block.dart';
import 'editor_toolbar.dart';

class CreateArticleScreen extends ConsumerStatefulWidget {
  final String? draftId;
  final String? existingContent;
  final List<String>? existingImages;

  const CreateArticleScreen({
    super.key,
    this.draftId,
    this.existingContent,
    this.existingImages,
  });

  @override
  ConsumerState<CreateArticleScreen> createState() =>
      _CreateArticleScreenState();
}

class _CreateArticleScreenState extends ConsumerState<CreateArticleScreen> {
  final List<EditorBlock> _blocks = [EditorBlock.paragraph()];
  int _activeIndex = 0;
  String? _currentDraftId;
  bool _didLoadInitialContent = false;

  @override
  void initState() {
    super.initState();
    _currentDraftId =
        widget.draftId ?? DateTime.now().millisecondsSinceEpoch.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_didLoadInitialContent) return;
      _didLoadInitialContent = true;

      if (widget.existingContent != null) {
        _loadFromDraft();
      }
    });
  }

  Future<void> _loadFromDraft() async {
    _blocks.clear();

    final lines = widget.existingContent!.split('\n');

    for (final rawLine in lines) {
      final line = rawLine.trimRight();

      // Skip empty lines
      if (line.trim().isEmpty) continue;

      // Check for heading
      if (line.startsWith('# ')) {
        _blocks.add(EditorBlock.heading()..controller.text = line.substring(2));
      }
      // Check for quote
      else if (line.startsWith('> ')) {
        _blocks.add(EditorBlock.quote()..controller.text = line.substring(2));
      }
      // Check for image marker
      else if (line.startsWith('[IMAGE:')) {
        final match = RegExp(r'\[IMAGE:(\d+)\]').firstMatch(line);
        if (match != null) {
          final index = int.parse(match.group(1)!);

          if (widget.existingImages != null &&
              index < widget.existingImages!.length) {
            final filename = widget.existingImages![index];

            // Get the full path from filename
            final file = await ImagePersistenceHelper.getImageFile(filename);

            if (file != null && await file.exists()) {
              _blocks.add(EditorBlock.image(file));
            }
          }
        }
      }
      // Check for bullet list
      else if (line.startsWith('- ')) {
        final block = EditorBlock.paragraph();
        block.isBullet = true;
        block.controller.text = line.substring(2);
        _blocks.add(block);
      }
      // Check for numbered list
      else if (RegExp(r'^\d+\. ').hasMatch(line)) {
        final block = EditorBlock.paragraph();
        block.isNumbered = true;
        block.controller.text = line.replaceFirst(RegExp(r'^\d+\. '), '');
        _blocks.add(block);
      }
      // Regular paragraph
      else {
        _blocks.add(EditorBlock.paragraph()..controller.text = line);
      }
    }

    // Ensure at least one block exists
    if (_blocks.isEmpty) {
      _blocks.add(EditorBlock.paragraph());
    }

    setState(() {});
  }

  void _setActive(int i) => setState(() => _activeIndex = i);

  void _toHeading() {
    final block = _blocks[_activeIndex];
    final controller = block.controller;
    final selection = controller.selection;

    if (!selection.isValid) return;

    final text = controller.text;
    final cursor = selection.baseOffset;

    final before = text.substring(0, cursor);
    final after = text.substring(cursor);

    final lastNewline = before.lastIndexOf('\n');
    final lineStart = lastNewline == -1 ? 0 : lastNewline + 1;

    final line = before.substring(lineStart).trim();
    if (line.isEmpty) return;

    final remaining = text.substring(0, lineStart) + after;

    setState(() {
      controller.text = remaining;

      _blocks.insert(
        _activeIndex,
        EditorBlock.heading()..controller.text = line,
      );

      _activeIndex++;
    });
  }

  void _toQuote() {
    setState(() {
      _blocks[_activeIndex] = EditorBlock.quote()
        ..controller.text = _blocks[_activeIndex].controller.text;
    });
  }

  Future<void> _addImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) return;

    final filename = await ImagePersistenceHelper.persistImage(img.path);
    if (filename.isEmpty) return;

    final file = await ImagePersistenceHelper.getImageFile(filename);
    if (file == null) return;

    setState(() {
      _blocks.insert(_activeIndex + 1, EditorBlock.image(file));
      _blocks.insert(_activeIndex + 2, EditorBlock.paragraph());
      _activeIndex += 2;
    });

    await _autoSaveDraft();
  }

  TextStyle _style(EditorBlock b) {
    switch (b.type) {
      case BlockType.heading:
        return const TextStyle(fontSize: 26, fontWeight: FontWeight.bold);
      case BlockType.quote:
        return const TextStyle(
          fontSize: 18,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        );
      default:
        return const TextStyle(fontSize: 18, height: 1.6);
    }
  }

  void _saveDraft() async {
    await _autoSaveDraft(silent: false);
  }

  Future<void> _autoSaveDraft({bool silent = true}) async {
    final draftsVM = ref.read(draftsViewModelProvider.notifier);

    final data = _serializeForStorage();
    final content = data['content'] as String;
    final images = data['images'] as List<String>;

    if (content.trim().isEmpty) return;

    final draft = Draft(
      id: _currentDraftId!,
      title: _extractTitle(),
      content: content,
      imagePaths: images,
      updatedAt: DateTime.now(),
      preview: _extractTitle(),
    );

    await draftsVM.saveDraft(draft);

    if (!silent && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Draft saved')));
    }
  }

  void _showMoreSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetItem(
                icon: Icons.save_outlined,
                label: 'Save draft',
                onTap: () {
                  _saveDraft();
                  Navigator.pop(context);
                },
              ),
              _sheetItem(
                icon: Icons.visibility_outlined,
                label: 'Preview',
                onTap: () {
                  Navigator.pop(context);
                  _previewArticle();
                },
              ),
              _sheetItem(
                icon: Icons.drafts_outlined,
                label: 'View drafts',
                onTap: () {
                  Navigator.pop(context);
                  _viewDrafts();
                },
              ),
              const Divider(),
              _sheetItem(
                icon: Icons.delete_outline,
                label: 'Discard draft',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _discardDraft();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }

  void _discardDraft() {
    setState(() {
      _blocks
        ..clear()
        ..add(EditorBlock.paragraph());
      _activeIndex = 0;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Draft discarded')));
  }

  void _previewArticle() {
    final data = _serializeForStorage();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticlePreviewScreen(
          content: data['content'],
          images: List<String>.from(data['images']),
        ),
      ),
    );
  }

  Future<void> _publish() async {
    final data = _serializeForStorage();
    final articleTitlePayLoad = _extractTitle();

    context.push(
      Routes.publishPreviewScreen,
      extra: {
        'title': articleTitlePayLoad,
        'content': data['content'] as String,
        'images': data['images'] as List<String>,
        "draftID": _currentDraftId,
      },
    );
  }

  void _viewDrafts() {
    context.push(Routes.draftsListScreen);
  }

  Map<String, dynamic> _serializeForStorage() {
    final buffer = StringBuffer();
    final images = <String>[];

    for (final b in _blocks) {
      switch (b.type) {
        case BlockType.heading:
          buffer.writeln('# ${b.controller.text}');
          break;

        case BlockType.quote:
          buffer.writeln('> ${b.controller.text}');
          break;

        case BlockType.image:
          final index = images.length;
          // Store only the filename, not the full path
          final filename = b.image!.path.split('/').last;
          images.add(filename);
          buffer.writeln('[IMAGE:$index]');
          break;

        default:
          if (b.isBullet) {
            final lines = b.controller.text.split('\n');
            for (final line in lines) {
              if (line.trim().isNotEmpty) {
                buffer.writeln('- $line');
              }
            }
          } else if (b.isNumbered) {
            final lines = b.controller.text.split('\n');
            for (int i = 0; i < lines.length; i++) {
              if (lines[i].trim().isNotEmpty) {
                buffer.writeln('${i + 1}. ${lines[i]}');
              }
            }
          } else {
            buffer.writeln(b.controller.text);
          }
      }
    }

    return {'content': buffer.toString(), 'images': images};
  }

  String _extractTitle() {
    for (final b in _blocks) {
      if (b.type != BlockType.image) {
        final t = b.controller.text.trim();
        if (t.isNotEmpty) return t;
      }
    }
    return "Untitled Article";
  }

  void _toggleBold() {
    final block = _blocks[_activeIndex];
    final c = block.controller;
    final sel = c.selection;

    if (!sel.isValid || sel.isCollapsed) return;

    final text = c.text;
    final selected = text.substring(sel.start, sel.end);
    final before = text.substring(0, sel.start);
    final after = text.substring(sel.end);

    final newText = "$before**$selected**$after";

    c.text = newText;
    c.selection = TextSelection.collapsed(
      offset: sel.start + selected.length + 4,
    );

    setState(() {});
  }

  void _toggleItalic() {
    final block = _blocks[_activeIndex];
    final c = block.controller;
    final sel = c.selection;

    if (!sel.isValid || sel.isCollapsed) return;

    final text = c.text;
    final selected = text.substring(sel.start, sel.end);
    final before = text.substring(0, sel.start);
    final after = text.substring(sel.end);

    final newText = "$before*$selected*$after";

    c.text = newText;
    c.selection = TextSelection.collapsed(
      offset: sel.start + selected.length + 2,
    );

    setState(() {});
  }

  void _toggleBullet() {
    final block = _blocks[_activeIndex];
    if (block.type != BlockType.paragraph) return;

    setState(() {
      block.isBullet = !block.isBullet;
      if (block.isBullet) block.isNumbered = false;
    });
  }

  void _toggleNumbered() {
    final block = _blocks[_activeIndex];
    if (block.type != BlockType.paragraph) return;

    setState(() {
      block.isNumbered = !block.isNumbered;
      if (block.isNumbered) block.isBullet = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<ApiResponse<String>>(articlePublishProvider, (prev, next) {
      if (next is Success<String>) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article published successfully')),
        );

        ref
            .read(draftsViewModelProvider.notifier)
            .deleteDraft(_currentDraftId!);
        ref.read(selectedCategoryProvider.notifier).state = null;
        context.go(Routes.home);
      } else if (next is Failure<String>) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _autoSaveDraft();
                    context.pop();
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: _showMoreSheet,
                ),
                const SizedBox(width: 8),
                Consumer(
                  builder: (_, ref, __) {
                    final publishState = ref.watch(articlePublishProvider);
                    final isPublishing = publishState is Loading<String>;

                    return GestureDetector(
                      onTap: isPublishing ? null : _publish,
                      child: isPublishing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: _blocks.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _blocks.removeAt(oldIndex);
            _blocks.insert(newIndex, item);
          });
        },
        itemBuilder: (_, i) {
          final b = _blocks[i];
          return KeyedSubtree(key: ValueKey(b.id), child: _buildBlock(b, i));
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: EditorToolbar(
            onHeading: _toHeading,
            onQuote: _toQuote,
            onBold: _toggleBold,
            onItalic: _toggleItalic,
            onImage: _addImage,
            onBullet: _toggleBullet,
            onNumbered: _toggleNumbered,
          ),
        ),
      ),
    );
  }

  Widget _buildBlock(EditorBlock editorBlock, int i) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (editorBlock.type == BlockType.image) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(editorBlock.image!),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black87),
                onPressed: () {
                  setState(() {
                    final file = editorBlock.image!;
                    final filename = file.path.split('/').last;
                    ImagePersistenceHelper.deleteImage(filename);
                    _blocks.removeAt(i);

                    if (_blocks.isEmpty) {
                      _blocks.add(EditorBlock.paragraph());
                    }

                    _activeIndex = (_activeIndex - 1).clamp(
                      0,
                      _blocks.length - 1,
                    );
                  });
                },
              ),
            ),
          ],
        ),
      );
    }

    if (editorBlock.isBullet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 8),
            child: Text(
              '•',
              style: _style(editorBlock).copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: editorBlock.controller,
              readOnly: editorBlock.readOnly,
              maxLines: null,
              style: _style(
                editorBlock,
              ).copyWith(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'List item...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                border: InputBorder.none,
              ),
              onTap: () => _setActive(i),
              onChanged: (_) => _autoSaveDraft(),
            ),
          ),
        ],
      );
    }

    if (editorBlock.isNumbered) {
      int number = 1;
      for (int j = 0; j < i; j++) {
        if (_blocks[j].isNumbered) number++;
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 8),
            child: SizedBox(
              width: 24,
              child: Text(
                '$number.',
                style: _style(editorBlock).copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: editorBlock.controller,
              readOnly: editorBlock.readOnly,
              maxLines: null,
              style: _style(
                editorBlock,
              ).copyWith(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'List item...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                border: InputBorder.none,
              ),
              onTap: () => _setActive(i),
              onChanged: (_) => _autoSaveDraft(),
            ),
          ),
        ],
      );
    }

    return TextField(
      controller: editorBlock.controller,
      readOnly: editorBlock.readOnly,
      maxLines: null,
      style: _style(
        editorBlock,
      ).copyWith(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: 'Tell your story...',
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
        border: InputBorder.none,
      ),
      onTap: () => _setActive(i),
      onChanged: (_) => _autoSaveDraft(),
    );
  }
}
