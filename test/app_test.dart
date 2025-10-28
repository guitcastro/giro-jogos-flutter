import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:giro_jogos/src/app.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
import 'package:mockito/mockito.dart';

// Mock AuthService for testing (completely independent of Firebase)
class MockAuthService extends ChangeNotifier implements AuthService {
  bool _isAuthenticated;
  User? _currentUser;

  MockAuthService({bool isAuthenticated = false, User? currentUser})
      : _isAuthenticated = isAuthenticated,
        _currentUser = currentUser;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    return null;
  }

  @override
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    return null;
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    return null;
  }

  @override
  Future<UserCredential?> signInWithApple() async {
    return null;
  }

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  // Helper method for testing
  void setAuthenticated(bool authenticated, [User? user]) {
    _isAuthenticated = authenticated;
    _currentUser = user;
    notifyListeners();
  }
}

// Mock User for testing
class MockUser extends Mock implements User {
  final String? _displayName;
  final String? _email;
  final String? _photoURL;

  MockUser({
    String? displayName,
    String? email,
    String? photoURL,
  }) : _displayName = displayName,
       _email = email,
       _photoURL = photoURL;

  @override
  String? get displayName => _displayName;
  
  @override
  String? get email => _email;
  
  @override
  String? get photoURL => _photoURL;
}

void main() {
  group('GiroJogosApp Tests', () {
    testWidgets('shows login screen when user is not authenticated',
        (WidgetTester tester) async {
      // Build our app with provider and trigger a frame.
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>(
          create: (_) => MockAuthService(isAuthenticated: false),
          child: const GiroJogosApp(),
        ),
      );

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Verify that the login screen is shown (since user is not authenticated)
      expect(find.text('Giro Jogos'), findsOneWidget);
      expect(find.text('Entre na sua conta'), findsOneWidget);
    });

    testWidgets('shows home screen with tabs when user is authenticated',
        (WidgetTester tester) async {
      // Create a mock user
      final mockUser = MockUser(
        displayName: 'Test User',
        email: 'test@example.com',
      );

      // Build our app with an authenticated user
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>(
          create: (_) => MockAuthService(isAuthenticated: true, currentUser: mockUser),
          child: const GiroJogosApp(),
        ),
      );

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Verify that the home screen is shown with tabs
      expect(find.text('Giro Jogos'), findsOneWidget);
      expect(find.text('Duo'), findsOneWidget);
      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('Duo & Equipe'), findsOneWidget);
    });

    testWidgets('shows user info in home screen when authenticated',
        (WidgetTester tester) async {
      // Create a mock user
      final mockUser = MockUser(
        displayName: 'João Silva',
        email: 'joao@example.com',
      );

      // Build our app with an authenticated user
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>(
          create: (_) => MockAuthService(isAuthenticated: true, currentUser: mockUser),
          child: const GiroJogosApp(),
        ),
      );

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // Verify that user info is displayed
      expect(find.text('Olá, João Silva!'), findsOneWidget);
      expect(find.text('Encontre seu parceiro de jogo'), findsOneWidget);
    });
  });
}