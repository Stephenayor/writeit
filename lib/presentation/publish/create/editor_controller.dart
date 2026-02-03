import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/helper/image_persistence_helper.dart';
import '../editor_block.dart';

enum BlockType { heading, paragraph, bulletListItem, numberedListItem, image }

class EditorBlockNode {
  final String id;
  BlockType type;
  final TextEditingController controller;
  final FocusNode focusNode;
  String? imagePath;

  EditorBlockNode.text(this.type, {String text = ''})
    : id = const Uuid().v4(),
      controller = TextEditingController(text: text),
      focusNode = FocusNode(),
      imagePath = null;

  EditorBlockNode.image(this.imagePath)
    : id = const Uuid().v4(),
      type = BlockType.image,
      controller = TextEditingController(),
      focusNode = FocusNode();
}

class EditorController extends ChangeNotifier {
  final List<EditorBlockNode> blocks = [];
  int _activeIndex = 0;

  int activeIndex = 0;

  EditorController() {
    // Medium behavior: first block is heading
    blocks.add(EditorBlockNode.text(BlockType.heading));
    blocks.add(EditorBlockNode.text(BlockType.paragraph));
  }

  EditorBlockNode get active => blocks[activeIndex];

  // -------------------------------
  // Keyboard behaviors
  // -------------------------------

  void ensureFirstIsHeading() {
    if (blocks.isEmpty) return;
    if (blocks.first.type != BlockType.heading) {
      blocks.first.type = BlockType.heading;
    }
  }

  void onEnter() {
    final current = active;
    final c = current.controller;
    final sel = c.selection;

    final text = c.text;
    final cursor = sel.baseOffset;

    final before = text.substring(0, cursor);
    final after = text.substring(cursor);

    // If current is empty list item → exit list
    if ((current.type == BlockType.bulletListItem ||
            current.type == BlockType.numberedListItem) &&
        text.trim().isEmpty) {
      current.type = BlockType.paragraph;
      notifyListeners();
      return;
    }

    // Split text
    c.text = before;

    final newType = _nextType(current);

    final newBlock = EditorBlockNode.text(newType, text: after);

    blocks.insert(activeIndex + 1, newBlock);
    activeIndex++;

    _focusActive();
    notifyListeners();
  }

  void onBackspaceAtStart() {
    if ((active.type == BlockType.bulletListItem ||
            active.type == BlockType.numberedListItem) &&
        active.controller.text.isEmpty) {
      active.type = BlockType.paragraph;
      notifyListeners();
      return;
    }

    if (activeIndex == 0) return;

    final current = active;
    final prev = blocks[activeIndex - 1];

    if (current.type == BlockType.image) {
      blocks.removeAt(activeIndex);
      activeIndex--;
      _focusActive();
      notifyListeners();
      return;
    }

    final prevText = prev.controller.text;
    final currText = current.controller.text;

    prev.controller.text = prevText + currText;

    blocks.removeAt(activeIndex);
    activeIndex--;

    _focusActive();
    notifyListeners();
  }

  // -------------------------------
  // Formatting
  // -------------------------------

  void toggleBullet() {
    _toggleList(BlockType.bulletListItem);
  }

  void toggleNumber() {
    _toggleList(BlockType.numberedListItem);
  }

  void _toggleList(BlockType type) {
    final current = active;
    if (current.type == type) {
      current.type = BlockType.paragraph;
    } else {
      current.type = type;
    }
    notifyListeners();
  }

  // -------------------------------
  // Images
  // -------------------------------

  void insertImage(String path) {
    final imageBlock = EditorBlockNode.image(path);
    final paragraph = EditorBlockNode.text(BlockType.paragraph);

    blocks.insert(activeIndex + 1, imageBlock);
    blocks.insert(activeIndex + 2, paragraph);

    activeIndex += 2;
    _focusActive();
    notifyListeners();
  }

  // -------------------------------
  // Helpers
  // -------------------------------

  BlockType _nextType(EditorBlockNode current) {
    if (current.type == BlockType.heading) {
      return BlockType.paragraph;
    }

    if (current.type == BlockType.bulletListItem) {
      // If empty → exit list
      if (current.controller.text.trim().isEmpty) {
        current.type = BlockType.paragraph;
        return BlockType.paragraph;
      }
      return BlockType.bulletListItem;
    }

    if (current.type == BlockType.numberedListItem) {
      if (current.controller.text.trim().isEmpty) {
        current.type = BlockType.paragraph;
        return BlockType.paragraph;
      }
      return BlockType.numberedListItem;
    }

    return BlockType.paragraph;
  }

  void _focusActive() {
    Future.microtask(() {
      active.focusNode.requestFocus();
    });
  }

  void updateText(int index, String newText) {
    blocks[index].controller.text = newText;
    notifyListeners();
  }

  void setActive(int index) {
    activeIndex = index;
    notifyListeners();
  }

  void loadFromSerialized(String content) {
    blocks.clear();

    final lines = content.split('\n');

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.startsWith('# ')) {
        blocks.add(
          EditorBlockNode.text(BlockType.heading, text: line.substring(2)),
        );
      } else if (line.startsWith('- ')) {
        blocks.add(
          EditorBlockNode.text(
            BlockType.bulletListItem,
            text: line.substring(2),
          ),
        );
      } else if (RegExp(r'^\d+\. ').hasMatch(line)) {
        blocks.add(
          EditorBlockNode.text(
            BlockType.numberedListItem,
            text: line.substring(3),
          ),
        );
      } else if (line.startsWith('[IMAGE:')) {
        final path = line.replaceAll('[IMAGE:', '').replaceAll(']', '');
        blocks.add(EditorBlockNode.image(path));
      } else {
        blocks.add(EditorBlockNode.text(BlockType.paragraph, text: line));
      }
    }

    if (blocks.isEmpty) {
      blocks.add(EditorBlockNode.text(BlockType.heading));
      blocks.add(EditorBlockNode.text(BlockType.paragraph));
    }

    activeIndex = blocks.length - 1;
    notifyListeners();
  }

  // Future<void> _addImage() async {
  //   final img = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   if (img == null) return;
  //
  //   final filename = await ImagePersistenceHelper.persistImage(img.path);
  //   if (filename.isEmpty) return;
  //
  //   final file = File(await ImagePersistenceHelper.getFullPath(filename));
  //
  //   setState(() {
  //     blocks.insert(
  //       _activeIndex + 1,
  //       EditorBlock.image(file) as EditorBlockNode,
  //     );
  //     blocks.insert(
  //       _activeIndex + 2,
  //       EditorBlock.paragraph() as EditorBlockNode,
  //     );
  //     _activeIndex += 2;
  //   });
  //
  //   // await _autoSaveDraft();
  // }

  String serialize() {
    final buffer = StringBuffer();

    for (final b in blocks) {
      switch (b.type) {
        case BlockType.heading:
          buffer.writeln('# ${b.controller.text}');
          break;
        case BlockType.bulletListItem:
          buffer.writeln('- ${b.controller.text}');
          break;
        case BlockType.numberedListItem:
          buffer.writeln('1. ${b.controller.text}');
          break;
        case BlockType.paragraph:
          buffer.writeln(b.controller.text);
          break;
        case BlockType.image:
          buffer.writeln('[IMAGE:${b.imagePath}]');
          break;
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  List<String> extractImages() {
    return blocks
        .where((b) => b.type == BlockType.image)
        .map((b) => b.imagePath!)
        .toList();
  }

  int indexOf(EditorBlockNode block) {
    return blocks.indexOf(block);
  }

  int computeNumber(int index) {
    int count = 1;

    for (int i = index - 1; i >= 0; i--) {
      if (blocks[i].type == BlockType.numberedListItem) {
        count++;
      } else {
        break;
      }
    }

    return count;
  }
}
