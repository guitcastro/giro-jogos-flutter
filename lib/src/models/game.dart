class Game {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final List<String> categories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Game({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.categories = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'categories': categories,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}
