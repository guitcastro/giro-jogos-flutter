/*
 * This file is part of Giro Jogos.
 * 
 * Giro Jogos is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Giro Jogos is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with Giro Jogos. If not, see <https://www.gnu.org/licenses/>.
 */

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
