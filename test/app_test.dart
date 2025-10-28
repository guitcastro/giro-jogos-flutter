import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:giro_jogos/src/app.dart';
import 'package:giro_jogos/src/services/auth_service.dart';

// Mock AuthService for testing (completely independent of Firebase)
class MockAuthService extends ChangeNotifier implements AuthService {
  bool _isAuthenticated = false;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  User? get currentUser => null;

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
  Future<void> signOut() async {}
}

void main() {
  testWidgets('GiroJogosApp has a title and shows login screen',
      (WidgetTester tester) async {
    // Build our app with provider and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>(
        create: (_) => MockAuthService(),
        child: const GiroJogosApp(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the login screen is shown (since user is not authenticated)
    expect(find.text('Giro Jogos'), findsOneWidget);
    expect(find.text('Entre na sua conta'), findsOneWidget);
  });
}
