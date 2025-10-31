import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/screens/home/settings_tab.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:giro_jogos/src/services/join_duo_params.dart';

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
      expect(find.byIcon(Icons.edit), findsOneWidget);
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
