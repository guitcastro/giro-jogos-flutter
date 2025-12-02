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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/screens/home/settings_tab.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:giro_jogos/src/services/join_duo_params.dart';
import 'package:material_symbols_icons/symbols.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

void main() {
  group('SettingsTab Tests', () {
    late MockAuthService mockAuthService;
    late MockUser mockUser;

    setUp(() {
      mockAuthService = MockAuthService();
      mockUser = MockUser();
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<AuthService>.value(
            value: mockAuthService,
            child: ChangeNotifierProvider<JoinDuoParams>(
              create: (_) => JoinDuoParams(),
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('should display user profile section',
        (WidgetTester tester) async {
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.photoURL).thenReturn(null);

      await tester.pumpWidget(createTestWidget(const SettingsTab()));

      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byIcon(Symbols.edit), findsOneWidget);
    });

    testWidgets('should render settings tab successfully',
        (WidgetTester tester) async {
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.photoURL).thenReturn(null);

      await tester.pumpWidget(createTestWidget(const SettingsTab()));

      // Verifica se o widget principal foi renderizado
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsAtLeastNWidgets(1));
    });
  });
}
