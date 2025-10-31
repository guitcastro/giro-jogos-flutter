import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:giro_jogos/src/screens/auth/login_screen.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
import 'package:giro_jogos/src/services/join_duo_params.dart';

// Mock AuthService for testing
class MockAuthService extends ChangeNotifier implements AuthService {
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
  bool _shouldThrowError = false;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  User? get currentUser => null;

  void setShouldThrowError(bool value) {
    _shouldThrowError = value;
  }

  @override
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    _lastEmail = email;
    _lastPassword = password;

    if (_shouldThrowError) {
      throw Exception('Test error');
    }

    _isAuthenticated = true;
    notifyListeners();
    return null;
  }

  @override
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    _lastEmail = email;
    _lastPassword = password;

    if (_shouldThrowError) {
      throw Exception('Test error');
    }

    _isAuthenticated = true;
    notifyListeners();
    return null;
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    if (_shouldThrowError) {
      throw Exception('Google sign in error');
    }

    _isAuthenticated = true;
    notifyListeners();
    return null;
  }

  @override
  Future<UserCredential?> signInWithApple() async {
    if (_shouldThrowError) {
      throw Exception('Apple sign in error');
    }

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
  testWidgets('exibe mensagem para login ao tentar entrar em dupla',
      (WidgetTester tester) async {
    // Setup igual aos outros testes
    final mockAuthService = MockAuthService();
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    // Cria JoinDuoParams com parâmetros para simular acesso via convite
    final joinDuoParams = JoinDuoParams();
    joinDuoParams.setParams('duo1', 'INVITE123');
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>.value(
        value: mockAuthService,
        child: ChangeNotifierProvider<JoinDuoParams>.value(
          value: joinDuoParams,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Faça login para se juntar à dupla'), findsOneWidget);
  });
  group('LoginScreen Widget Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    setUpAll(() {
      // Configure uma tela maior para todos os testes
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<AuthService>.value(
        value: mockAuthService,
        child: ChangeNotifierProvider<JoinDuoParams>(
          create: (_) => JoinDuoParams(),
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
    }

    // Helper para configurar o tamanho da tela nos testes
    void setLargerScreenSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
    }

    testWidgets('should display login form elements',
        (WidgetTester tester) async {
      setLargerScreenSize(tester);
      await tester.pumpWidget(createTestWidget());

      // Verify UI elements are present
      expect(find.text('Giro Jogos'), findsOneWidget);
      expect(find.text('Entre na sua conta'), findsOneWidget);
      expect(find.byType(TextFormField),
          findsNWidgets(2)); // Email and password fields
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Não tem uma conta? Cadastre-se'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
    });

    testWidgets('should toggle between sign in and sign up mode',
        (WidgetTester tester) async {
      setLargerScreenSize(tester);
      await tester.pumpWidget(createTestWidget());

      // Initially in sign in mode
      expect(find.text('Entre na sua conta'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Não tem uma conta? Cadastre-se'), findsOneWidget);

      // Tap toggle button
      await tester.tap(find.text('Não tem uma conta? Cadastre-se'));
      await tester.pump();

      // Now in sign up mode
      expect(find.text('Criar sua conta'), findsOneWidget);
      expect(find.text('Criar Conta'), findsOneWidget);
      expect(find.text('Já tem uma conta? Entre aqui'), findsOneWidget);
    });

    testWidgets('should show and hide password', (WidgetTester tester) async {
      setLargerScreenSize(tester);
      await tester.pumpWidget(createTestWidget());

      // Find password field and visibility toggle
      final passwordField = find.byKey(const Key('passwordField'));
      final visibilityIcon = find.byIcon(Icons.visibility);

      // Initially password should be hidden
      expect(passwordField, findsOneWidget);
      expect(visibilityIcon, findsOneWidget);

      // Tap visibility toggle
      await tester.tap(visibilityIcon);
      await tester.pump();

      // Check that visibility icon changed to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      setLargerScreenSize(tester);
      await tester.pumpWidget(createTestWidget());

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Tap sign in button
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Digite um email válido'), findsOneWidget);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      setLargerScreenSize(tester);
      await tester.pumpWidget(createTestWidget());

      // Tap sign in button without entering data
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Should show validation errors
      expect(find.text('Por favor, digite seu email'), findsOneWidget);
      expect(find.text('Por favor, digite sua senha'), findsOneWidget);
    });

    testWidgets('should call signInWithEmailAndPassword when form is valid',
        (WidgetTester tester) async {
      setLargerScreenSize(tester);
      await tester.pumpWidget(createTestWidget());

      // Enter valid credentials
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Tap sign in button
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Wait for async operations
      await tester.pumpAndSettle();

      // Verify auth service was called with correct parameters
      expect(mockAuthService.lastEmail, equals('test@example.com'));
      expect(mockAuthService.lastPassword, equals('password123'));
    });

    testWidgets('should handle Google sign in tap',
        (WidgetTester tester) async {
      setLargerScreenSize(tester);
      await tester.pumpWidget(createTestWidget());

      // Tap Google sign in button
      await tester.tap(find.text('Google'));
      await tester.pump();

      // In a real implementation, this would verify Google sign in was called
      // For now, we just verify the button can be tapped without errors
      expect(tester.takeException(), isNull);
    });
    testWidgets('should show error message on authentication failure',
        (WidgetTester tester) async {
      setLargerScreenSize(tester);
      await tester.pumpWidget(createTestWidget());

      // Configure mock to throw error
      mockAuthService.setShouldThrowError(true);

      // Enter valid credentials
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Tap sign in button
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Wait for async operations and SnackBar animation
      await tester.pumpAndSettle();

      // Deve exibir mensagem de erro em SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Exception: Test error'), findsOneWidget);
    });

    testWidgets('deve exibir botão do Google ativo',
        (WidgetTester tester) async {
      setLargerScreenSize(tester);
      await tester.pumpWidget(createTestWidget());

      final googleButtonFinder = find.byKey(const Key('googleSignInButton'));
      expect(googleButtonFinder, findsOneWidget);
      final buttonWidget = tester.widget<OutlinedButton>(googleButtonFinder);
      expect(buttonWidget.onPressed != null, isTrue,
          reason: 'O botão do Google deve estar habilitado');
    });
  });
}
