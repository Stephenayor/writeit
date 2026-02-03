import 'package:flutter/material.dart';
import 'package:writeit/presentation/publish/article_preview_screen.dart';
import 'editor_controller.dart';
import 'editor_view.dart';

class CreateArticleV2Screen extends StatefulWidget {
  const CreateArticleV2Screen({super.key});

  @override
  State<CreateArticleV2Screen> createState() => _CreateArticleV2ScreenState();
}

class _CreateArticleV2ScreenState extends State<CreateArticleV2Screen> {
  late final EditorController editor;

  @override
  void initState() {
    super.initState();
    editor = EditorController();

    // final draft = loadDraftIfExists(); // your existing logic
    // if (draft != null) {
    //   editor.loadFromSerialized(draft.content);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Write"),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye),
            onPressed: () {
              final content = editor.serialize();
              final images = editor.extractImages();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ArticlePreviewScreen(content: content, images: images),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final content = editor.serialize();
              final images = editor.extractImages();
              // save draft EXACTLY like before
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: EditorView(controller: editor)),
          _Toolbar(editor: editor),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final EditorController editor;

  const _Toolbar({required this.editor});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            onPressed: editor.toggleBullet,
          ),
          IconButton(
            icon: const Icon(Icons.format_list_numbered),
            onPressed: editor.toggleNumber,
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () async {
              // pick image, then:
              // editor.insertImage(path);
            },
          ),
        ],
      ),
    );
  }
}
