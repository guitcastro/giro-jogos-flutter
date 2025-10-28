import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/screens/home/duo_tab.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockAuthService extends Mock implements AuthService {}
class MockUser extends Mock implements User {}

void main() {
  group('DuoTab Tests', () {
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
            child: SizedBox(
              width: 800,
              height: 1000,
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('should display welcome message with user info', (WidgetTester tester) async {
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.photoURL).thenReturn(null);

      await tester.pumpWidget(createTestWidget(const DuoTab()));

      expect(find.text('Olá, Test User!'), findsOneWidget);
      expect(find.text('Encontre seu parceiro de jogo'), findsOneWidget);
    });

    testWidgets('should display all action cards', (WidgetTester tester) async {
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.photoURL).thenReturn(null);

      await tester.pumpWidget(createTestWidget(const DuoTab()));

      expect(find.text('Encontrar Duo'), findsOneWidget);
      expect(find.text('Criar Equipe'), findsOneWidget);
      expect(find.text('Buscar Equipe'), findsOneWidget);
      expect(find.text('Partidas Agendadas'), findsOneWidget);
      
      expect(find.byIcon(Icons.person_add), findsOneWidget);
      expect(find.byIcon(Icons.group_add), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('should display section title', (WidgetTester tester) async {
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.photoURL).thenReturn(null);

      await tester.pumpWidget(createTestWidget(const DuoTab()));

      expect(find.text('Duo & Equipe'), findsOneWidget);
    });
  });
}