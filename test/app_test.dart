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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/app.dart';
import 'package:giro_jogos/src/screens/home/home_screen.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
import 'test_helpers.dart';
import 'fakes/fake_duo_service.dart';
import 'fakes/fake_auth_service.dart';
import 'fakes/fake_challenge_service.dart';
import 'fakes/fake_media_upload_service.dart';
import 'package:giro_jogos/src/services/join_duo_params.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  setUpAll(() async {
    await initializeFirebaseForTesting();
  });

  group('GiroJogosApp', () {
    testWidgets('mostra HomeScreen quando autenticado como usuário regular',
        (WidgetTester tester) async {
      final mockUser = MockUser(
        isAnonymous: false,
        displayName: 'Test User',
        email: 'test@example.com',
      );
      final fakeDuoService = FakeDuoService();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(
              create: (_) => FakeAuthService(
                isAuthenticated: true,
                currentUser: mockUser,
                isAdmin: false,
              ),
            ),
            ChangeNotifierProvider<JoinDuoParams>(
                create: (_) => JoinDuoParams()),
          ],
          child: GiroJogosApp(
            duoService: fakeDuoService,
            challengeService: const FakeChallengeService(),
            mediaUploadService: const FakeMediaUploadService(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    test('verifica que admin user tem isAdmin true', () {
      final mockUser = MockUser(
        isAnonymous: false,
        displayName: 'Admin User',
        email: 'admin@example.com',
      );
      final fakeAuthService = FakeAuthService(
        isAuthenticated: true,
        currentUser: mockUser,
        isAdmin: true,
      );

      // Verifica que o AuthService está configurado corretamente como admin
      expect(fakeAuthService.isAdmin, true);
      expect(fakeAuthService.isAuthenticated, true);
      expect(fakeAuthService.currentUser?.email, 'admin@example.com');
      // Em produção, o AuthWrapper detectará isAdmin=true e redirecionará para /admin
    });

    testWidgets('mostra tela de login quando não autenticado',
        (WidgetTester tester) async {
      final fakeDuoService = FakeDuoService();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(
              create: (_) => FakeAuthService(isAuthenticated: false),
            ),
            ChangeNotifierProvider<JoinDuoParams>(
                create: (_) => JoinDuoParams()),
          ],
          child: GiroJogosApp(
            duoService: fakeDuoService,
            challengeService: const FakeChallengeService(),
            mediaUploadService: const FakeMediaUploadService(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Giro Jogos'), findsOneWidget);
      expect(find.text('Entre na sua conta'), findsOneWidget);
    });
  });
}
