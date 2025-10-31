import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/app.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../test_helpers.dart';
import '../fakes/fake_duo_service.dart';

// Fake AuthService for integration testing (completely independent of Firebase)
class FakeAuthService extends ChangeNotifier implements AuthService {
  @override
  bool get isAuthLoading => false;

  PendingJoinInfo? _pendingJoin;
  @override
  PendingJoinInfo? get pendingJoin => _pendingJoin;
  @override
  set pendingJoin(PendingJoinInfo? value) {
    _pendingJoin = value;
    notifyListeners();
  }

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
  setUpAll(() async {
    await initializeFirebaseForTesting();
  });

  group('Authentication Integration Tests', () {
    late FakeAuthService fakeAuthService;

    setUp(() {
      fakeAuthService = FakeAuthService();
    });

    Widget createApp() {
      final fakeDuoService = FakeDuoService();
      return ChangeNotifierProvider<AuthService>.value(
        value: fakeAuthService,
        child: GiroJogosApp(duoService: fakeDuoService),
      );
    }

    // Helper para configurar o tamanho da tela nos testes
    void setLargerScreenSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
    }

    testWidgets('complete authentication flow - login to home screen',
        (WidgetTester tester) async {
      setLargerScreenSize(tester);
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Should start at login screen
      expect(find.text('Giro Jogos'), findsOneWidget);
      expect(find.text('Entre na sua conta'), findsOneWidget);

      // Enter valid credentials
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Tap login button
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Deve navegar para a home após login
      expect(find.text('Dupla'), findsOneWidget); // Tab
      expect(find.text('Configurações'), findsOneWidget); // Tab
      expect(find.text('Entre na sua conta'), findsNothing);
    });

    testWidgets('navigation between login and signup modes',
        (WidgetTester tester) async {
      setLargerScreenSize(tester);
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Should start in login mode
      expect(find.text('Entre na sua conta'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);

      // Switch to signup mode
      await tester.tap(find.text('Não tem uma conta? Cadastre-se'));
      await tester.pumpAndSettle();

      // Should be in signup mode
      expect(find.text('Criar sua conta'), findsOneWidget);
      expect(find.text('Criar Conta'), findsOneWidget);

      // Switch back to login mode
      await tester.tap(find.text('Já tem uma conta? Entre aqui'));
      await tester.pumpAndSettle();

      // Should be back in login mode
      expect(find.text('Entre na sua conta'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('logout flow - home screen to login screen',
        (WidgetTester tester) async {
      setLargerScreenSize(tester);
      // Start with authenticated user
      fakeAuthService._isAuthenticated = true;

      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Deve estar na home (tab 'Dupla' visível)
      expect(find.text('Dupla'), findsOneWidget);

      // Look for logout option in app bar menu (PopupMenuButton)
      final userMenuButton = find.byType(PopupMenuButton<String>);
      expect(userMenuButton, findsOneWidget);

      await tester.tap(userMenuButton);
      await tester.pumpAndSettle();

      // Tap logout option
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      // Deve voltar para tela de login
      expect(find.text('Entre na sua conta'), findsOneWidget);
      expect(find.text('Dupla'), findsNothing);
    });

    testWidgets('form validation prevents submission with invalid data',
        (WidgetTester tester) async {
      setLargerScreenSize(tester);
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Try to submit form without any data
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Por favor, digite seu email'), findsOneWidget);
      expect(find.text('Por favor, digite sua senha'), findsOneWidget);

      // Should still be on login screen
      expect(find.text('Entre na sua conta'), findsOneWidget);
    });

    testWidgets('error handling for invalid credentials',
        (WidgetTester tester) async {
      setLargerScreenSize(tester);
      await tester.pumpWidget(createApp());
      await tester.pumpAndSettle();

      // Enter invalid credentials
      await tester.enterText(
          find.byType(TextFormField).first, 'invalid@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');

      // Try to login
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Should handle the error gracefully (stay on login screen)
      expect(find.text('Entre na sua conta'), findsOneWidget);

      // Should show error message in AlertDialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Erro'), findsOneWidget);
      expect(find.text('User not found'), findsOneWidget);
    });
  });
}
