import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'block_node.dart';
import 'editor_controller.dart';

class EditorView extends StatelessWidget {
  final EditorController controller;

  const EditorView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.blocks.length,
          itemBuilder: (context, index) {
            final block = controller.blocks[index];

            if (block.type == BlockType.image) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Image.file(File(block.imagePath!)),
              );
            }

            final textBlock = block;
            return KeyedSubtree(
              key: ValueKey(block.id), // ✅ CRITICAL
              child: _TextBlock(
                block: textBlock,
                index: index,
                controller: controller,
              ),
            );

            // return _TextBlock(
            //   block: textBlock,
            //   index: index,
            //   controller: controller,
            // );
          },
        );
      },
    );
  }
}

class _TextBlock extends StatefulWidget {
  final EditorBlockNode block;
  final int index;
  final EditorController controller;

  const _TextBlock({
    required this.block,
    required this.index,
    required this.controller,
  });

  @override
  State<_TextBlock> createState() => _TextBlockState();
}

class _TextBlockState extends State<_TextBlock> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = widget.block.controller;
    _focusNode = widget.block.focusNode;

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.controller.setActive(widget.index);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _TextBlock oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.block != widget.block) {
      _textController = widget.block.controller;
      _focusNode = widget.block.focusNode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final block = widget.block;

    String? prefix;

    if (block.type == BlockType.bulletListItem) {
      prefix = "•";
    } else if (block.type == BlockType.numberedListItem) {
      final index = widget.controller.indexOf(block);
      prefix = "${widget.controller.computeNumber(index)}.";
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (prefix != null)
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 8),
            child: Text(prefix, style: const TextStyle(fontSize: 18)),
          ),
        RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                widget.controller.onEnter();
              } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
                final c = widget.block.controller;
                if (c.selection.baseOffset == 0) {
                  widget.controller.onBackspaceAtStart();
                }
              }
            }
          },
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            maxLines: null,
            decoration: const InputDecoration(border: InputBorder.none),
            style: _styleFor(block.type),
            textInputAction: TextInputAction.newline,
          ),
        ),
      ],
    );
  }

  TextStyle _styleFor(BlockType type) {
    switch (type) {
      case BlockType.heading:
        return const TextStyle(fontSize: 26, fontWeight: FontWeight.bold);
      default:
        return const TextStyle(fontSize: 16);
    }
  }
}
