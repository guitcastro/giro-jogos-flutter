import 'package:flutter_test/flutter_test.dart';
import 'package:giro_jogos/src/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User should be created with required fields', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.isAdmin, false);
      expect(user.displayName, null);
    });

    test('User should serialize to JSON correctly', () {
      final now = DateTime.now();
      final user = User(
        id: '123',
        email: 'test@example.com',
        displayName: 'Test User',
        isAdmin: true,
        createdAt: now,
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['email'], 'test@example.com');
      expect(json['displayName'], 'Test User');
      expect(json['isAdmin'], true);
      expect(json['createdAt'], now.toIso8601String());
    });

    test('User should deserialize from JSON correctly', () {
      final now = DateTime.now();
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'isAdmin': true,
        'createdAt': now.toIso8601String(),
      };

      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.isAdmin, true);
      expect(user.createdAt.toIso8601String(), now.toIso8601String());
    });
  });
}
