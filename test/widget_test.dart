// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import 'package:giro_jogos/src/app.dart';
// import 'package:giro_jogos/src/screens/home/home_screen.dart';
import 'package:giro_jogos/src/services/auth_service.dart';
// import 'package:giro_jogos/src/services/duo_service.dart';
import 'package:giro_jogos/src/app.dart';

import 'test_helpers.dart';
import 'screens/home/duo_tab_test.dart' show MockDuoService;

// Mock AuthService for testing (completely independent of Firebase)
class MockAuthService extends ChangeNotifier implements AuthService {
  final bool _isAuthenticated = false;

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
  setUpAll(() async {
    await initializeFirebaseForTesting();
  });
  testWidgets('GiroJogosApp loads correctly', (WidgetTester tester) async {
    final mockDuoService = MockDuoService();
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>(
        create: (_) => MockAuthService(),
        child: GiroJogosApp(duoService: mockDuoService),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Giro Jogos'), findsOneWidget);
  });
}
