import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/screens/home/duo_tab.dart';

import 'package:giro_jogos/src/services/auth_service.dart';
import 'package:giro_jogos/src/services/duo_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../test_helpers.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

class MockDuoService extends Mock implements DuoService {}

void main() {
  setUpAll(() async {
    await initializeFirebaseForTesting();
  });

  group('DuoTab Tests', () {
    late MockAuthService mockAuthService;
    late MockUser mockUser;
    late MockDuoService mockDuoService;

    setUp(() {
      mockAuthService = MockAuthService();
      mockUser = MockUser();
      mockDuoService = MockDuoService();
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<AuthService>.value(
            value: mockAuthService,
            child: SizedBox(
              width: 800,
              height: 1000,
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('should display welcome message with user info',
        (WidgetTester tester) async {
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.photoURL).thenReturn(null);

      await tester
          .pumpWidget(createTestWidget(DuoTab(duoService: mockDuoService)));

      expect(find.text('Olá, Test User!'), findsOneWidget);
      expect(find.text('Gerencie seus duos e equipes'), findsOneWidget);
    });

    testWidgets('should display all action cards', (WidgetTester tester) async {
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.photoURL).thenReturn(null);

      await tester
          .pumpWidget(createTestWidget(DuoTab(duoService: mockDuoService)));

      expect(find.text('Criar Duo'), findsOneWidget);
      expect(find.text('Entrar em Duo'), findsOneWidget);
      expect(find.text('Buscar Equipe'), findsOneWidget);
      expect(find.text('Partidas Agendadas'), findsOneWidget);

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.group_add), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('should display section title', (WidgetTester tester) async {
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.photoURL).thenReturn(null);

      await tester
          .pumpWidget(createTestWidget(DuoTab(duoService: mockDuoService)));

      expect(find.text('Duo & Equipe'), findsOneWidget);
    });
  });
}
