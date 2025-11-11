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
import 'package:provider/provider.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:giro_jogos/src/models/duo.dart';
import 'package:giro_jogos/src/screens/duo/join_duo_screen.dart';
import '../../fakes/fake_auth_service.dart';
import '../../fakes/fake_duo_service.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
import 'package:giro_jogos/src/services/duo_service.dart';
import 'package:giro_jogos/src/services/join_duo_params.dart';

import 'package:go_router/go_router.dart';

void main() {
  group('JoinDuoScreen', () {
    Widget buildTestApp({
      required Widget child,
      required AuthService authService,
      required DuoService duoService,
    }) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: authService),
          Provider<DuoService>.value(value: duoService),
          ChangeNotifierProvider<JoinDuoParams>(create: (_) => JoinDuoParams()),
        ],
        child: MaterialApp(
          home: Scaffold(body: child),
        ),
      );
    }

    // ...existing tests...

    testWidgets('Navigating to /join/:duoId/:inviteCode shows JoinDuoScreen',
        (WidgetTester tester) async {
      final fakeUser = MockUser(
        isAnonymous: false,
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      final authService =
          FakeAuthService(isAuthenticated: true, currentUser: fakeUser);
      final duoService = FakeDuoService();
      duoService.stubGetUserDuo(() async => null);
      duoService.stubGetDuoByInviteCode((
              {required String duoId, required String inviteCode}) async =>
          _FakeDuo());

      final router = GoRouter(
        initialLocation: '/join/duo123/INVITE42',
        routes: [
          GoRoute(
            path: '/join/:duoId/:inviteCode',
            builder: (context, state) {
              final duoId = state.pathParameters['duoId'] ?? '';
              final inviteCode = state.pathParameters['inviteCode'] ?? '';
              return JoinDuoScreen(duoId: duoId, inviteCode: inviteCode);
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: authService),
            Provider<DuoService>.value(value: duoService),
            ChangeNotifierProvider<JoinDuoParams>(
                create: (_) => JoinDuoParams()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verifica se a tela de JoinDuoScreen está presente
      expect(find.byType(JoinDuoScreen), findsOneWidget);
      expect(find.text('Entrar nesta dupla'), findsOneWidget);
    });

    testWidgets('exibe erro se já estiver em uma dupla', (tester) async {
      final duoService = FakeDuoService();
      final fakeUser = MockUser(
        isAnonymous: false,
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      final authService =
          FakeAuthService(isAuthenticated: true, currentUser: fakeUser);
      final fakeDuo = _FakeDuo();
      await tester.pumpWidget(
        buildTestApp(
          child: JoinDuoScreen(
            duoId: 'duo1',
            inviteCode: 'ABC123',
            userDuo: fakeDuo,
          ),
          authService: authService,
          duoService: duoService,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Você já está em uma dupla.'), findsOneWidget);
    });

    testWidgets('exibe erro se a dupla não for encontrada', (tester) async {
      final duoService = FakeDuoService();
      duoService.stubGetDuoByInviteCode(
          ({required String duoId, required String inviteCode}) async => null);
      final fakeUser = MockUser(
        isAnonymous: false,
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      final authService =
          FakeAuthService(isAuthenticated: true, currentUser: fakeUser);
      await tester.pumpWidget(
        buildTestApp(
          child: const JoinDuoScreen(duoId: 'duo1', inviteCode: 'ABC123'),
          authService: authService,
          duoService: duoService,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Dupla não encontrada.'), findsOneWidget);
    });

    testWidgets('exibe erro se a dupla estiver cheia', (tester) async {
      final duoService = FakeDuoService();
      duoService.stubGetDuoByInviteCode((
              {required String duoId, required String inviteCode}) async =>
          _FakeDuo(isFull: true));
      final fakeUser = MockUser(
        isAnonymous: false,
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      final authService =
          FakeAuthService(isAuthenticated: true, currentUser: fakeUser);
      await tester.pumpWidget(
        buildTestApp(
          child: const JoinDuoScreen(duoId: 'duo1', inviteCode: 'ABC123'),
          authService: authService,
          duoService: duoService,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Esta dupla já está completa.'), findsOneWidget);
    });

    testWidgets('chama joinDuo se tudo estiver correto', (tester) async {
      final duoService = FakeDuoService();
      duoService.stubGetDuoByInviteCode((
              {required String duoId, required String inviteCode}) async =>
          _FakeDuo());
      var joinCalled = false;
      duoService.stubJoinDuo(({required Duo duo}) async {
        joinCalled = true;
      });
      final fakeUser = MockUser(
        isAnonymous: false,
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      final authService =
          FakeAuthService(isAuthenticated: true, currentUser: fakeUser);
      await tester.pumpWidget(
        buildTestApp(
          child: const JoinDuoScreen(duoId: 'duo1', inviteCode: 'ABC123'),
          authService: authService,
          duoService: duoService,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // Simula o clique no botão de confirmação
      final button = find.widgetWithText(ElevatedButton, 'Entrar nesta dupla');
      expect(button, findsOneWidget);
      await tester.tap(button);
      await tester.pump();
      expect(joinCalled, isTrue);
    });
  });
}

class _FakeDuo extends Duo {
  _FakeDuo({bool isFull = false})
      : super(
          id: 'duo1',
          participants: isFull
              ? [
                  const DuoParticipant(id: 'user1', name: 'User 1'),
                  const DuoParticipant(id: 'user2', name: 'User 2')
                ]
              : [const DuoParticipant(id: 'user1', name: 'User 1')],
          name: 'Dupla Teste',
          inviteCode: 'ABC123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  @override
  bool get isFull => participants.length >= 2;
}
