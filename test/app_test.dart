import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/app.dart';
import 'package:giro_jogos/src/screens/home/home_screen.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
import 'test_helpers.dart';
import 'fakes/fake_duo_service.dart';
import 'fakes/fake_auth_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  setUpAll(() async {
    await initializeFirebaseForTesting();
  });

  group('GiroJogosApp', () {
    testWidgets('mostra HomeScreen quando autenticado',
        (WidgetTester tester) async {
      final mockUser = MockUser(
        isAnonymous: false,
        displayName: 'Test User',
        email: 'test@example.com',
      );
      final fakeDuoService = FakeDuoService();
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>(
          create: (_) =>
              FakeAuthService(isAuthenticated: true, currentUser: mockUser),
          child: GiroJogosApp(duoService: fakeDuoService),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('mostra tela de login quando não autenticado',
        (WidgetTester tester) async {
      final fakeDuoService = FakeDuoService();
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>(
          create: (_) => FakeAuthService(isAuthenticated: false),
          child: GiroJogosApp(duoService: fakeDuoService),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Giro Jogos'), findsOneWidget);
      expect(find.text('Entre na sua conta'), findsOneWidget);
    });
  });
}
