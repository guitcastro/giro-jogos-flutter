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
import 'package:giro_jogos/src/app.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import '../test_helpers.dart';
import '../fakes/fake_challenge_service.dart';
import '../fakes/fake_duo_service.dart';
import '../fakes/fake_media_upload_service.dart';
import '../fakes/fake_terms_service.dart';
import 'package:giro_jogos/src/services/terms_service.dart';

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
  User? _mockUser;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  bool get isAdmin => false;

  @override
  User? get currentUser => _mockUser;

  @override
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    _lastEmail = email;
    _lastPassword = password;

    // Simulate successful login
    if (email == 'test@example.com' && password == 'password123') {
      _isAuthenticated = true;
      _mockUser = MockUser(
        uid: 'test-user-id',
        email: email,
        displayName: 'Test User',
      );
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
    _mockUser = MockUser(
      uid: 'test-user-id',
      email: email,
      displayName: 'Test User',
    );
    notifyListeners();
    return null;
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    // Simulate successful Google login
    _isAuthenticated = true;
    _mockUser = MockUser(
      uid: 'test-user-id',
      email: 'test@google.com',
      displayName: 'Google User',
    );
    notifyListeners();
    return null;
  }

  @override
  Future<UserCredential?> signInWithApple() async {
    // Simulate successful Apple login
    _isAuthenticated = true;
    _mockUser = MockUser(
      uid: 'test-user-id',
      email: 'test@apple.com',
      displayName: 'Apple User',
    );
    notifyListeners();
    return null;
  }

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    _mockUser = null;
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
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: fakeAuthService),
          Provider<TermsService>.value(
              value: FakeTermsService(acceptedInitially: true)),
        ],
        child: GiroJogosApp(
          duoService: FakeDuoService(),
          challengeService: const FakeChallengeService(),
          mediaUploadService: const FakeMediaUploadService(),
          termsService: FakeTermsService(acceptedInitially: true),
        ),
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
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Enter valid credentials
      await tester.enterText(
          find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

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
      fakeAuthService._mockUser = MockUser(
        uid: 'test-user-id',
        email: 'test@example.com',
        displayName: 'Test User',
      );

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
      expect(find.byType(TextFormField), findsNWidgets(2));
      await tester.enterText(
          find.byType(TextFormField).at(0), 'invalid@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');

      // Try to login
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      // Ensure snackbars are processed
      await tester.pump(const Duration(milliseconds: 100));

      // Should handle the error gracefully (stay on login screen)
      expect(find.text('Entre na sua conta'), findsOneWidget);

      // Deve exibir mensagem de erro em SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('User not found'), findsOneWidget);
    });
  });
}
