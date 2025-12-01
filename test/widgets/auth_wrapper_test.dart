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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:giro_jogos/src/auth_wrapper.dart';
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
  bool _isAdmin = false;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  bool get isAdmin => _isAdmin;

  @override
  User? get currentUser => null;

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void setAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

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
    notifyListeners();
  }
}

void main() {
  group('AuthWrapper Widget Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    Widget createTestWidget(Widget child) {
      return ChangeNotifierProvider<AuthService>.value(
        value: mockAuthService,
        child: ChangeNotifierProvider<JoinDuoParams>(
          create: (_) => JoinDuoParams(),
          child: MaterialApp(
            home: AuthWrapper(child: child),
          ),
        ),
      );
    }

    testWidgets('should show login screen when user is not authenticated',
        (WidgetTester tester) async {
      // Set user as not authenticated
      mockAuthService.setAuthenticated(false);

      const testChild = Scaffold(
        body: Center(child: Text('Protected Content')),
      );

      await tester.pumpWidget(createTestWidget(testChild));
      await tester.pump();

      // Should show login screen instead of protected content
      expect(find.text('Giro Jogos'), findsOneWidget);
      expect(find.text('Entre na sua conta'), findsOneWidget);
      expect(find.text('Protected Content'), findsNothing);
    });

    testWidgets('should show protected content when user is authenticated',
        (WidgetTester tester) async {
      // Set user as authenticated
      mockAuthService.setAuthenticated(true);

      const testChild = Scaffold(
        body: Center(child: Text('Protected Content')),
      );

      await tester.pumpWidget(createTestWidget(testChild));
      await tester.pump();

      // Should show protected content
      expect(find.text('Protected Content'), findsOneWidget);
      expect(find.text('Entre na sua conta'), findsNothing);
    });

    testWidgets('should react to authentication state changes',
        (WidgetTester tester) async {
      // Start with unauthenticated user
      mockAuthService.setAuthenticated(false);

      const testChild = Scaffold(
        body: Center(child: Text('Protected Content')),
      );

      await tester.pumpWidget(createTestWidget(testChild));
      await tester.pump();

      // Should show login screen
      expect(find.text('Entre na sua conta'), findsOneWidget);
      expect(find.text('Protected Content'), findsNothing);

      // Authenticate user
      mockAuthService.setAuthenticated(true);
      await tester.pump();

      // Should now show protected content
      expect(find.text('Protected Content'), findsOneWidget);
      expect(find.text('Entre na sua conta'), findsNothing);

      // Sign out user
      mockAuthService.setAuthenticated(false);
      await tester.pump();

      // Should show login screen again
      expect(find.text('Entre na sua conta'), findsOneWidget);
      expect(find.text('Protected Content'), findsNothing);
    });

    testWidgets('should allow regular user to access non-admin route',
        (WidgetTester tester) async {
      // Set user as authenticated but not admin
      mockAuthService.setAuthenticated(true);
      mockAuthService.setAdmin(false);

      const testChild = Scaffold(
        body: Center(child: Text('User Content')),
      );

      await tester.pumpWidget(createTestWidget(testChild));
      await tester.pump();

      // Should show user content
      expect(find.text('User Content'), findsOneWidget);
    });

    testWidgets('should verify admin status is checked correctly',
        (WidgetTester tester) async {
      // Start as non-admin
      mockAuthService.setAuthenticated(true);
      mockAuthService.setAdmin(false);

      expect(mockAuthService.isAdmin, false);

      // Promote to admin
      mockAuthService.setAdmin(true);

      expect(mockAuthService.isAdmin, true);
    });
  });
}
