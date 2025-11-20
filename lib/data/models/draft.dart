class Draft {
  final String id;
  final String title;
  final String content;
  final List<String> imagePaths;
  final DateTime updatedAt;
  final String preview;

  Draft({
    required this.id,
    required this.title,
    required this.content,
    required this.imagePaths,
    required this.updatedAt,
    required this.preview,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "imagePaths": imagePaths,
    "updatedAt": updatedAt.toIso8601String(),
    "preview": preview,
  };

  static Draft fromJson(Map<String, dynamic> json) => Draft(
    id: json["id"],
    title: json["title"],
    content: json["content"],
    imagePaths: List<String>.from(json["imagePaths"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    preview: json["preview"],
  );
}
