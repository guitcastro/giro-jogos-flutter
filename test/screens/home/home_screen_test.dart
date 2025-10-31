import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/screens/home/home_screen.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
import 'package:giro_jogos/src/services/duo_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../test_helpers.dart';
import '../../fakes/fake_auth_service.dart';
import '../../fakes/fake_duo_service.dart';
import 'package:giro_jogos/src/screens/home/settings_tab.dart';

import 'package:giro_jogos/src/services/join_duo_params.dart';

class FakeUser implements User {
  @override
  String get uid => 'mock-uid';
  @override
  String? get displayName => 'Test User';
  @override
  String? get email => 'test@example.com';
  @override
  String? get photoURL => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    await initializeFirebaseForTesting();
  });

  group('HomeScreen Tests', () {
    late FakeAuthService fakeAuthService;
    late FakeUser fakeUser;
    late FakeDuoService fakeDuoService;

    setUp(() {
      fakeUser = FakeUser();
      fakeAuthService =
          FakeAuthService(isAuthenticated: true, currentUser: fakeUser);
      fakeDuoService = FakeDuoService();
      // Garante que o stream nunca acessa Firebase
      fakeDuoService.stubGetUserDuo(() async => null);
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Provider<DuoService>.value(
          value: fakeDuoService,
          child: ChangeNotifierProvider<AuthService>.value(
            value: fakeAuthService,
            child: ChangeNotifierProvider<JoinDuoParams>(
              create: (_) => JoinDuoParams(),
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('should display navigation bar with Duo and Settings',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(createTestWidget(HomeScreen(duoService: fakeDuoService)));
      // NavigationBar labels and icons
      expect(find.text('Dupla'), findsOneWidget);
      expect(find.text('Configurações'), findsOneWidget);
      expect(find.byIcon(Icons.group), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      // NavigationBar widget
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('should display app bar with title and menu icon',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(createTestWidget(HomeScreen(duoService: fakeDuoService)));
      expect(find.text('Giro Jogos'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should show popup menu when menu icon is tapped',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(createTestWidget(HomeScreen(duoService: fakeDuoService)));
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text('Admin Panel'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
      expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('should switch screens when navigation bar item is tapped',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(createTestWidget(HomeScreen(duoService: fakeDuoService)));
      // Começa na tela 0 (Dupla)
      expect(find.text('Dupla'), findsOneWidget);
      expect(find.text('Configurações'), findsOneWidget);
      // Toca no item de Configurações
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      // A tela de Configurações deve estar visível (SettingsTab)
      expect(find.byType(SettingsTab), findsOneWidget);
    });
  });
}
