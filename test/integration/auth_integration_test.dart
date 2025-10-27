import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/app.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Mock AuthService for integration testing
class MockAuthService extends ChangeNotifier implements AuthService {
  bool _isAuthenticated = false;
  String? _lastEmail;
  String? _lastPassword;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  User? get currentUser => null;

  @override
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    _lastEmail = email;
    _lastPassword = password;

    // Simulate successful login
    if (email == 'test@example.com' && password == 'password123') {
      _isAuthenticated = true;
      notifyListeners();
      return null; // Normally would return UserCredential
    }

    // Simulate authentication error
    throw FirebaseAuthException(
      code: 'user-not-found',
      message: 'User not found',
    );
  }

  @override
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    _lastEmail = email;
    _lastPassword = password;

    // Simulate successful signup
    _isAuthenticated = true;
    notifyListeners();
    return null;
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    // Simulate successful Google login
    _isAuthenticated = true;
    notifyListeners();
    return null;
  }

  @override
  Future<UserCredential?> signInWithApple() async {
    // Simulate successful Apple login
    _isAuthenticated = true;
    notifyListeners();
    return null;
  }

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    notifyListeners();
  }

  // Getter methods for testing
  String? get lastEmail => _lastEmail;
  String? get lastPassword => _lastPassword;
}

void main() {
  group('Authentication Integration Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    Widget createApp() {
      return ChangeNotifierProvider<AuthService>.value(
        value: mockAuthService,
        child: const GiroJogosApp(),
      );
    }

    testWidgets('complete authentication flow - login to home screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      await tester.pump();

      // Should start at login screen
      expect(find.text('Giro Jogos'), findsOneWidget);
      expect(find.text('Entre na sua conta'), findsOneWidget);

      // Enter valid credentials
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Tap login button
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Should navigate to home screen after successful login
      expect(find.text('Welcome to Giro Jogos!'), findsOneWidget);
      expect(find.text('Entre na sua conta'), findsNothing);
    });

    testWidgets('navigation between login and signup modes',
        (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      await tester.pump();

      // Should start in login mode
      expect(find.text('Entre na sua conta'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);

      // Switch to signup mode
      await tester.tap(find.text('Não tem uma conta? Cadastre-se'));
      await tester.pump();

      // Should be in signup mode
      expect(find.text('Criar sua conta'), findsOneWidget);
      expect(find.text('Criar Conta'), findsOneWidget);

      // Switch back to login mode
      await tester.tap(find.text('Já tem uma conta? Entre aqui'));
      await tester.pump();

      // Should be back in login mode
      expect(find.text('Entre na sua conta'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('logout flow - home screen to login screen',
        (WidgetTester tester) async {
      // Start with authenticated user
      mockAuthService._isAuthenticated = true;

      await tester.pumpWidget(createApp());
      await tester.pump();

      // Should be at home screen
      expect(find.text('Welcome to Giro Jogos!'), findsOneWidget);

      // Look for logout option in app bar menu
      final userMenuButton = find.byType(PopupMenuButton<String>);
      if (userMenuButton.evaluate().isNotEmpty) {
        await tester.tap(userMenuButton);
        await tester.pump();

        // Tap logout option
        await tester.tap(find.text('Sair'));
        await tester.pump();

        // Should return to login screen
        expect(find.text('Entre na sua conta'), findsOneWidget);
        expect(find.text('Welcome to Giro Jogos!'), findsNothing);
      }
    });

    testWidgets('form validation prevents submission with invalid data',
        (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      await tester.pump();

      // Try to submit form without any data
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Should show validation errors
      expect(find.text('Por favor, digite seu email'), findsOneWidget);
      expect(find.text('Por favor, digite sua senha'), findsOneWidget);

      // Should still be on login screen
      expect(find.text('Entre na sua conta'), findsOneWidget);
    });

    testWidgets('error handling for invalid credentials',
        (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      await tester.pump();

      // Enter invalid credentials
      await tester.enterText(
          find.byType(TextFormField).first, 'invalid@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');

      // Try to login
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Should handle the error gracefully (stay on login screen)
      expect(find.text('Entre na sua conta'), findsOneWidget);

      // Note: In a real implementation, you would also check for error messages
      // displayed to the user (e.g., SnackBar)
    });
  });
}
