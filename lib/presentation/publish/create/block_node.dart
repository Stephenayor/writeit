import '../editor_block.dart';

class BlockNode {
  final String id;
  BlockType type;
  String text;
  String? imagePath;

  BlockNode({
    required this.id,
    required this.type,
    this.text = '',
    this.imagePath,
  });

  bool get isText => type != BlockType.image;
  bool get isList =>
      type == BlockType.bulletListItem || type == BlockType.numberedListItem;
}
