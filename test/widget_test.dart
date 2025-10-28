// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
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
  testWidgets('GiroJogosApp loads correctly', (WidgetTester tester) async {
    // Build our app with provider and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>(
        create: (_) => MockAuthService(),
        child: const GiroJogosApp(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the app loads without errors and shows login screen
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Giro Jogos'), findsOneWidget);
  });
}
