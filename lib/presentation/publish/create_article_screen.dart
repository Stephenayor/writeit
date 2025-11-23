import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:writeit/core/utils/routes.dart';
import 'dart:io';
import '../../core/network/api_response.dart';
import '../../data/models/draft.dart';
import '../../providers/providers.dart';
import 'article_preview_screen.dart';

class CreateArticleScreen extends ConsumerStatefulWidget {
  final String? draftId;
  final String? existingContent;
  final List<String>? existingImages;

  const CreateArticleScreen({
    Key? key,
    this.draftId,
    this.existingContent,
    this.existingImages,
  }) : super(key: key);

  @override
  ConsumerState<CreateArticleScreen> createState() =>
      _CreateArticleScreenState();
}

class _CreateArticleScreenState extends ConsumerState<CreateArticleScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> _images = [];
  bool _isFirstLine = true;
  String? _currentDraftId;
  Timer? _autoSaveTimer;
  Timer? _saveStatusClearTimer;
  bool _hasSavedOnce = false;
  String _saveStatus = "";
  Timer? _backgroundAutoSaveTimer;
  String? _lastSavedContent;
  DateTime? _lastSavedTime;
  bool _isManualSaving = false;

  @override
  void initState() {
    super.initState();

    // Load existing draft if provided
    if (widget.existingContent != null) {
      _controller.text = widget.existingContent!;
      _isFirstLine = false;
    }

    if (widget.draftId != null) {
      final draftsViewModel = ref.read(draftsViewModelProvider.notifier);
      final loadedDraft = draftsViewModel.getDraftById(widget.draftId!);

      if (loadedDraft != null) {
        _controller.text = loadedDraft.content;
        _images.addAll(widget.existingImages!);
        _isFirstLine = false;
      }
    }

    if (widget.existingImages != null) {
      _images.addAll(widget.existingImages!);
    }

    _currentDraftId =
        widget.draftId ?? DateTime.now().millisecondsSinceEpoch.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _saveToDrafts(silent: true);
    });
    _backgroundAutoSaveTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _autoSaveBackground(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _autoSaveTimer?.cancel();
    _saveStatusClearTimer?.cancel();
    super.dispose();
  }

  String _capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String _extractTitle() {
    final lines = _controller.text.split('\n');
    for (final line in lines) {
      final cleaned = line.replaceAll('**', '').trim();
      if (cleaned.isNotEmpty && !cleaned.startsWith('[IMAGE:')) {
        return cleaned;
      }
    }
    return 'Untitled Article';
  }

  Future<void> _saveToDrafts({bool silent = false}) async {
    final draftsVM = ref.read(draftsViewModelProvider.notifier);
    final content = _controller.text;

    if (content.trim().isEmpty) {
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot save empty article')),
        );
      }
      return;
    }

    final draft = Draft(
      id: _currentDraftId!,
      title: _extractTitle(),
      content: _controller.text,
      imagePaths: _images,
      updatedAt: DateTime.now(),
      preview: _extractTitle(),
    );

    _isManualSaving = true;
    await draftsVM.saveDraft(draft);
    _isManualSaving = false;

    final state = ref.read(draftsViewModelProvider);

    if (state.error != null && !silent) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error!)));
    }

    setState(() {
      _lastSavedContent = content;
      _lastSavedTime = DateTime.now();
    });

    if (state.draft.isNotEmpty) {
      setState(() => _saveStatus = "Saved");

      _saveStatusClearTimer?.cancel();
      _saveStatusClearTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _saveStatus = "");
        }
      });

      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to drafts: ${_extractTitle()}'),
            action: SnackBarAction(
              label: 'VIEW',
              onPressed: () {
                context.push(Routes.draftsListScreen);
              },
            ),
          ),
        );
      }
    }

    if (!silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to drafts: ${_extractTitle()}'),
          action: SnackBarAction(
            label: 'VIEW',
            onPressed: () {
              context.push(Routes.draftsListScreen);
            },
          ),
        ),
      );
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.save_outlined),
                title: const Text('Save to Drafts'),
                onTap: () {
                  Navigator.pop(context);
                  _saveToDrafts();
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('Preview Article'),
                onTap: () {
                  Navigator.pop(context);
                  _showPreview();
                },
              ),
              ListTile(
                leading: const Icon(Icons.drafts_outlined),
                title: const Text('View Drafts'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(Routes.draftsListScreen);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ArticlePreviewScreen(content: _controller.text, images: _images),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      final cursorPos = _controller.selection.base.offset;
      final text = _controller.text;

      final imageMarker = '\n[IMAGE:${_images.length}]\n';
      final newText =
          text.substring(0, cursorPos) +
          imageMarker +
          text.substring(cursorPos);

      setState(() {
        _images.add(image.path);
      });

      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: cursorPos + imageMarker.length,
        ),
      );

      _focusNode.requestFocus();
      scheduleAutoSave();
    }
  }

  String _formatTime(DateTime time) {
    return "${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}";
  }

  Future<void> _autoSaveDraftSilently() async {
    final vm = ref.read(draftsViewModelProvider.notifier);
    final content = _controller.text.trim();

    if (content.isEmpty) return;

    final draft = Draft(
      id: _currentDraftId!,
      title: _extractTitle(),
      content: content,
      imagePaths: _images,
      updatedAt: DateTime.now(),
      preview: _extractTitle(),
    );

    await vm.saveDraft(draft);

    if (!_hasSavedOnce) {
      _hasSavedOnce = true;
      print("Auto-saved draft: ${draft.title}");
    }
  }

  void scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 1500), () {
      _autoSaveDraftSilently();
    });
  }

  Future<void> _autoSaveBackground() async {
    final content = _controller.text.trim();

    // do not save empty draft
    if (content.isEmpty) return;

    // do not save if nothing changed
    if (_lastSavedContent == content) return;

    final draft = Draft(
      id: _currentDraftId!,
      title: _extractTitle(),
      content: _controller.text,
      imagePaths: _images,
      updatedAt: DateTime.now(),
      preview: _extractTitle(),
    );

    final vm = ref.read(draftsViewModelProvider.notifier);
    await vm.saveDraft(draft);

    if (mounted) {
      setState(() {
        _lastSavedContent = content;
        _lastSavedTime = DateTime.now();
      });
    }
  }

  void _toggleBoldOrFormat() {
    final selection = _controller.selection;
    if (!selection.isValid || selection.isCollapsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select text first'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final text = _controller.text;
    final selectedText = text.substring(selection.start, selection.end);

    final isBold = selectedText.startsWith('**') && selectedText.endsWith('**');

    String newText;
    int newCursorPos;

    if (isBold) {
      final unboldText = selectedText.substring(2, selectedText.length - 2);
      newText =
          text.substring(0, selection.start) +
          unboldText +
          text.substring(selection.end);
      newCursorPos = selection.start + unboldText.length;
    } else {
      newText =
          '${text.substring(0, selection.start)}**$selectedText**${text.substring(selection.end)}';
      newCursorPos = selection.start + selectedText.length + 4;
    }

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  void _showFormatMenu() {
    final selection = _controller.selection;
    if (!selection.isValid || selection.isCollapsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select text first'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.format_bold),
                title: const Text('Bold'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleBoldOrFormat();
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_italic),
                title: const Text('Italic'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleItalic();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Add Hyperlink'),
                onTap: () {
                  Navigator.pop(context);
                  _addLink();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleItalic() {
    final selection = _controller.selection;
    if (!selection.isValid || selection.isCollapsed) return;

    final text = _controller.text;
    final selectedText = text.substring(selection.start, selection.end);

    final isItalic =
        selectedText.startsWith('*') &&
        selectedText.endsWith('*') &&
        !selectedText.startsWith('**');

    String newText;
    int newCursorPos;

    if (isItalic) {
      final unitalicText = selectedText.substring(1, selectedText.length - 1);
      newText =
          text.substring(0, selection.start) +
          unitalicText +
          text.substring(selection.end);
      newCursorPos = selection.start + unitalicText.length;
    } else {
      newText =
          '${text.substring(0, selection.start)}*$selectedText*${text.substring(selection.end)}';
      newCursorPos = selection.start + selectedText.length + 2;
    }

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  void _addLink() {
    final selection = _controller.selection;
    if (!selection.isValid || selection.isCollapsed) return;

    final text = _controller.text;
    final selectedText = text.substring(selection.start, selection.end);

    final linkFormat = '[$selectedText](https://)';
    final newText =
        text.substring(0, selection.start) +
        linkFormat +
        text.substring(selection.end);

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + linkFormat.length - 1,
      ),
    );
  }

  void _insertQuote() {
    final cursorPos = _controller.selection.base.offset;
    final text = _controller.text;

    final textBeforeCursor = text.substring(0, cursorPos);
    final lastNewline = textBeforeCursor.lastIndexOf('\n');
    final currentLineStart = lastNewline == -1 ? 0 : lastNewline + 1;
    final currentLine = text.substring(currentLineStart, cursorPos);

    String insertion;
    if (currentLine.trim().isEmpty) {
      insertion = '> ';
    } else {
      insertion = '\n> ';
    }

    final newText =
        text.substring(0, cursorPos) + insertion + text.substring(cursorPos);

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + insertion.length),
    );
  }

  void _insertBullet() {
    final cursorPos = _controller.selection.base.offset;
    final text = _controller.text;

    final textBeforeCursor = text.substring(0, cursorPos);
    final lastNewline = textBeforeCursor.lastIndexOf('\n');
    final currentLineStart = lastNewline == -1 ? 0 : lastNewline + 1;
    final currentLine = text.substring(currentLineStart, cursorPos);

    String insertion;
    if (currentLine.trim().isEmpty) {
      insertion = '• ';
    } else {
      insertion = '\n• ';
    }

    final newText =
        text.substring(0, cursorPos) + insertion + text.substring(cursorPos);

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + insertion.length),
    );
  }

  void _insertNumberedList() {
    final cursorPos = _controller.selection.base.offset;
    final text = _controller.text;

    final textBeforeCursor = text.substring(0, cursorPos);
    final lastNewline = textBeforeCursor.lastIndexOf('\n');
    final currentLineStart = lastNewline == -1 ? 0 : lastNewline + 1;
    final currentLine = text.substring(currentLineStart, cursorPos);

    int number = 1;
    final lines = textBeforeCursor.split('\n');
    for (var line in lines.reversed) {
      final match = RegExp(r'^(\d+)\.\s').firstMatch(line.trim());
      if (match != null) {
        number = int.parse(match.group(1)!) + 1;
        break;
      }
    }

    String insertion;
    if (currentLine.trim().isEmpty) {
      insertion = '$number. ';
    } else {
      insertion = '\n$number. ';
    }

    final newText =
        text.substring(0, cursorPos) + insertion + text.substring(cursorPos);

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + insertion.length),
    );
  }

  void _insertDivider() {
    final cursorPos = _controller.selection.base.offset;
    final text = _controller.text;

    final insertion = '\n\n• • •\n\n';
    final newText =
        text.substring(0, cursorPos) + insertion + text.substring(cursorPos);

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPos + insertion.length),
    );
  }

  bool _handleEnterKey() {
    final cursorPos = _controller.selection.base.offset;
    final text = _controller.text;

    final textBeforeCursor = text.substring(0, cursorPos);
    final lastNewline = textBeforeCursor.lastIndexOf('\n');
    final currentLineStart = lastNewline == -1 ? 0 : lastNewline + 1;
    final currentLine = text.substring(currentLineStart, cursorPos);
    final textAfterCursor = text.substring(cursorPos);

    // Handle first line as heading - FIXED LOGIC
    if (_isFirstLine &&
        currentLine.trim().isNotEmpty &&
        !currentLine.contains('[IMAGE:')) {
      // Extract clean text without any markers
      final cleanText = currentLine.trim();

      // Capitalize each word
      final heading = '${_capitalizeWords(cleanText)}';

      // Replace current line with formatted heading
      final newText = '$heading\n\n$textAfterCursor';

      setState(() {
        _isFirstLine = false;
      });

      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: heading.length + 2),
      );
      return true;
    }

    // Mark as not first line after any Enter
    if (_isFirstLine) {
      setState(() {
        _isFirstLine = false;
      });
    }

    // Rest of the enter key logic...
    // (quote, bullet, numbered list handling)

    // Check for quote
    if (currentLine.trim().startsWith('>')) {
      if (currentLine.trim() == '>') {
        final newText =
            '${text.substring(0, currentLineStart)}\n$textAfterCursor';
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: currentLineStart + 1),
        );
        return true;
      } else {
        final newText = '${text.substring(0, cursorPos)}\n> $textAfterCursor';
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: cursorPos + 3),
        );
        return true;
      }
    }

    // Check for bullet list
    if (currentLine.trim().startsWith('•')) {
      if (currentLine.trim() == '•') {
        final newText =
            '${text.substring(0, currentLineStart)}\n$textAfterCursor';
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: currentLineStart + 1),
        );
        return true;
      } else {
        final newText = '${text.substring(0, cursorPos)}\n• $textAfterCursor';
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: cursorPos + 3),
        );
        return true;
      }
    }

    // Check for numbered list
    final numberMatch = RegExp(r'^(\d+)\.\s').firstMatch(currentLine.trim());
    if (numberMatch != null) {
      final currentNumber = int.parse(numberMatch.group(1)!);
      final contentAfterNumber = currentLine.substring(
        currentLine.indexOf('. ') + 2,
      );

      if (contentAfterNumber.trim().isEmpty) {
        final newText =
            '${text.substring(0, currentLineStart)}\n$textAfterCursor';
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: currentLineStart + 1),
        );
        return true;
      } else {
        final nextNumber = currentNumber + 1;
        final newText =
            '${text.substring(0, cursorPos)}\n$nextNumber. $textAfterCursor';
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: cursorPos + nextNumber.toString().length + 3,
          ),
        );
        return true;
      }
    }

    return false;
  }

  Widget _buildContentWithImages(bool isDark) {
    final text = _controller.text;
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      final imageMatch = RegExp(r'\[IMAGE:(\d+)\]').firstMatch(line);

      if (imageMatch != null) {
        final imageIndex = int.parse(imageMatch.group(1)!);
        if (imageIndex < _images.length) {
          widgets.add(
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_images[imageIndex]),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        padding: const EdgeInsets.all(4),
                        minimumSize: const Size(28, 28),
                      ),
                      onPressed: () {
                        setState(() {
                          final marker = '[IMAGE:$imageIndex]';
                          _controller.text = _controller.text.replaceAll(
                            '\n$marker\n',
                            '\n',
                          );
                          _images.removeAt(imageIndex);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildRichEditor(bool isDark) {
    final text = _controller.text;

    final parts = text.split(RegExp(r'(\[IMAGE:\d+\])'));
    final children = <Widget>[];

    for (final part in parts) {
      final imageMatch = RegExp(r'\[IMAGE:(\d+)\]').firstMatch(part);

      if (imageMatch != null) {
        final index = int.parse(imageMatch.group(1)!);

        if (index < _images.length) {
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_images[index]),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          // Remove from text also
                          _controller.text = _controller.text.replaceAll(
                            part,
                            "",
                          );
                          _images.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      } else {
        // this is regular text → render a TextField segment
        children.add(
          TextField(
            controller: _controller,
            maxLines: null,
            focusNode: _focusNode,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saveState = ref.watch(draftsViewModelProvider);
    final publishState = ref.watch(articlePublishProvider);
    final isPublishing = publishState is Loading<String>;

    ref.listen<ApiResponse<String>>(articlePublishProvider, (previous, next) {
      if (next is Success<String>) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article published successfully')),
        );
        final draftsViewModel = ref.read(draftsViewModelProvider.notifier);
        draftsViewModel.deleteDraft(widget.draftId!);
        context.go(Routes.home);
      } else if (next is Failure<String>) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'Close',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        leadingWidth: 80,
        actions: [
          IconButton(
            onPressed: isPublishing ? null : _showMoreOptions,
            icon: Icon(
              Icons.more_horiz,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          TextButton(
            onPressed: isPublishing ? null : onPublish,
            child: isPublishing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Publish',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContentWithImages(isDark),

                  RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (event) {
                      if (event is RawKeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.enter) {
                          if (_handleEnterKey()) {
                            // Handled
                          }
                        }
                      }
                    },
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.6,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tell your story...',
                        hintStyle: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        border: OutlineInputBorder(),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 300),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildToolButton(
                  label: 'Tt',
                  onTap: _toggleBoldOrFormat,
                  onLongPress: _showFormatMenu,
                  isDark: isDark,
                  tooltip: 'Tap: Bold | Long press: More',
                ),
                _buildToolButton(
                  icon: Icons.format_quote,
                  onTap: _insertQuote,
                  onLongPress: _showFormatMenu,
                  isDark: isDark,
                  tooltip: 'Tap: Quote | Long press: Format',
                ),
                _buildToolButton(
                  icon: Icons.circle,
                  onTap: _insertBullet,
                  isDark: isDark,
                  tooltip: 'Bullet',
                ),
                _buildToolButton(
                  icon: Icons.format_list_numbered,
                  onTap: _insertNumberedList,
                  isDark: isDark,
                  tooltip: 'Numbered',
                ),
                _buildToolButton(
                  icon: Icons.more_horiz,
                  onTap: _insertDivider,
                  isDark: isDark,
                  tooltip: '• • •',
                ),
                const Spacer(),
                _buildToolButton(
                  icon: Icons.image_outlined,
                  onTap: _pickImage,
                  isDark: isDark,
                  tooltip: 'Image',
                ),
              ],
            ),
          ),

          if (saveState.isSaving)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                "Saving...",
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),

          if (saveState.draft.isNotEmpty && _saveStatus.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "Saved",
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
            ),

          if (saveState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "Error: ${saveState.error}",
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          if (_lastSavedTime != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "Last saved at ${_formatTime(_lastSavedTime!)}",
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> onPublish() async {
    final createArticleViewModel = ref.read(articlePublishProvider.notifier);
    final title = _extractTitle();
    final content = _controller.text;
    final images = List<String>.from(_images);

    await createArticleViewModel.publishArticle(
      title: title,
      rawContent: content,
      localImagePaths: images,
    );
  }

  Widget _buildToolButton({
    IconData? icon,
    String? label,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    required bool isDark,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: label != null
              ? Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                )
              : Icon(
                  icon,
                  size: 22,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
        ),
      ),
    );
  }
}
