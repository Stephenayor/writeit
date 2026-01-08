import 'dart:io';

import 'package:flutter/cupertino.dart';

enum BlockType { paragraph, heading, quote, image }

class EditorBlock {
  BlockType type;
  TextEditingController controller;
  File? image;
  final String id = UniqueKey().toString();
  bool readOnly = false;
  bool isBullet = false;
  bool isNumbered = false;

  EditorBlock.paragraph()
    : type = BlockType.paragraph,
      controller = TextEditingController(),
      image = null;

  EditorBlock.heading()
    : type = BlockType.heading,
      controller = TextEditingController(),
      image = null;

  EditorBlock.quote()
    : type = BlockType.quote,
      controller = TextEditingController(),
      image = null;

  EditorBlock.image(this.image)
    : type = BlockType.image,
      controller = TextEditingController();
}
