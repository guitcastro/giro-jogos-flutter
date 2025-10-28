import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/screens/home/home_screen.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
import 'package:giro_jogos/src/services/duo_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../test_helpers.dart';

class MockDuoService extends Mock implements DuoService {}

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

void main() {
  setUpAll(() async {
    await initializeFirebaseForTesting();
  });

  group('HomeScreen Tests', () {
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
        home: ChangeNotifierProvider<AuthService>.value(
          value: mockAuthService,
          child: child,
        ),
      );
    }

    testWidgets('should display tab bar with Duo and Settings tabs',
        (WidgetTester tester) async {
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.photoURL).thenReturn(null);

      await tester
          .pumpWidget(createTestWidget(HomeScreen(duoService: mockDuoService)));

      expect(find.text('Duo'), findsOneWidget);
      expect(find.text('Configurações'), findsOneWidget);
      expect(find.byIcon(Icons.group), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should display app bar with title and user avatar',
        (WidgetTester tester) async {
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.photoURL).thenReturn(null);

      await tester
          .pumpWidget(createTestWidget(HomeScreen(duoService: mockDuoService)));

      expect(find.text('Giro Jogos'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsAtLeastNWidgets(1));
    });

    testWidgets('should show popup menu when avatar is tapped',
        (WidgetTester tester) async {
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.photoURL).thenReturn(null);

      await tester
          .pumpWidget(createTestWidget(HomeScreen(duoService: mockDuoService)));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('Admin Panel'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
      expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('should display user initial when no photo URL is provided',
        (WidgetTester tester) async {
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.photoURL).thenReturn(null);

      await tester
          .pumpWidget(createTestWidget(HomeScreen(duoService: mockDuoService)));

      expect(find.text('T'),
          findsAtLeastNWidgets(1)); // First letter of "Test User"
    });
  });
}
