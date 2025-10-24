import 'package:flutter_test/flutter_test.dart';
import 'package:giro_jogos/src/models/game.dart';

void main() {
  group('Game Model Tests', () {
    test('Game should be created with required fields', () {
      final now = DateTime.now();
      final game = Game(
        id: 'game123',
        title: 'Test Game',
        description: 'A test game description',
        createdAt: now,
        updatedAt: now,
      );

      expect(game.id, 'game123');
      expect(game.title, 'Test Game');
      expect(game.description, 'A test game description');
      expect(game.isActive, true);
      expect(game.categories.length, 0);
    });

    test('Game should serialize to JSON correctly', () {
      final now = DateTime.now();
      final game = Game(
        id: 'game123',
        title: 'Test Game',
        description: 'A test game description',
        imageUrl: 'https://example.com/image.png',
        categories: ['Action', 'Adventure'],
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      final json = game.toJson();

      expect(json['id'], 'game123');
      expect(json['title'], 'Test Game');
      expect(json['description'], 'A test game description');
      expect(json['imageUrl'], 'https://example.com/image.png');
      expect(json['categories'], ['Action', 'Adventure']);
      expect(json['isActive'], true);
    });

    test('Game should deserialize from JSON correctly', () {
      final now = DateTime.now();
      final json = {
        'id': 'game123',
        'title': 'Test Game',
        'description': 'A test game description',
        'imageUrl': 'https://example.com/image.png',
        'categories': ['Action', 'Adventure'],
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'isActive': true,
      };

      final game = Game.fromJson(json);

      expect(game.id, 'game123');
      expect(game.title, 'Test Game');
      expect(game.description, 'A test game description');
      expect(game.imageUrl, 'https://example.com/image.png');
      expect(game.categories, ['Action', 'Adventure']);
      expect(game.isActive, true);
    });
  });
}
