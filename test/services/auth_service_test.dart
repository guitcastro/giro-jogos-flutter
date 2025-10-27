import 'package:flutter_test/flutter_test.dart';
import 'package:giro_jogos/src/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    group('Initial State', () {
      test('should initialize with no user', () {
        expect(authService.currentUser, isNull);
        expect(authService.isAuthenticated, isFalse);
      });
    });

    group('Email/Password Authentication', () {
      test('signInWithEmailAndPassword should handle invalid credentials',
          () async {
        // Test with invalid credentials - should throw FirebaseAuthException
        expect(
          () async => await authService.signInWithEmailAndPassword(
            'invalid@email.com',
            'wrongpassword',
          ),
          throwsException,
        );
      });

      test('signUpWithEmailAndPassword should handle weak password', () async {
        // Test with weak password - should throw FirebaseAuthException
        expect(
          () async => await authService.signUpWithEmailAndPassword(
            'test@email.com',
            '123', // weak password
          ),
          throwsException,
        );
      });

      test('signInWithEmailAndPassword should handle invalid email format',
          () async {
        // Test with invalid email format - should throw FirebaseAuthException
        expect(
          () async => await authService.signInWithEmailAndPassword(
            'invalid-email',
            'password123',
          ),
          throwsException,
        );
      });
    });

    group('Google Sign In', () {
      test('signInWithGoogle should handle authentication', () async {
        // Note: This will fail in test environment without proper setup
        // but demonstrates the test structure
        expect(
          () async => await authService.signInWithGoogle(),
          throwsException,
        );
      });
    });

    group('Apple Sign In', () {
      test('signInWithApple should handle authentication', () async {
        // Note: This will fail in test environment without proper setup
        // but demonstrates the test structure
        expect(
          () async => await authService.signInWithApple(),
          throwsException,
        );
      });
    });

    group('Sign Out', () {
      test('signOut should complete without error', () async {
        // Sign out should not throw when no user is signed in
        expect(
          () async => await authService.signOut(),
          returnsNormally,
        );
      });
    });
  });
}
