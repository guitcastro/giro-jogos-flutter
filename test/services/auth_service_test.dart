import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:giro_jogos/src/services/auth_service.dart';

// Mock AuthService for testing (avoiding Firebase dependency)
class MockAuthServiceForTest extends ChangeNotifier implements AuthService {
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
  User? _user;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  User? get currentUser => _user;

  @override
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    // Simulate invalid credentials
    if (email == 'invalid@email.com' && password == 'wrongpassword') {
      throw FirebaseAuthException(
          code: 'user-not-found', message: 'User not found');
    }

    // Simulate invalid email format
    if (!email.contains('@')) {
      throw FirebaseAuthException(
          code: 'invalid-email', message: 'Invalid email');
    }

    // Simulate successful login
    _isAuthenticated = true;
    notifyListeners();
    return null; // Mock credential
  }

  @override
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    // Simulate weak password
    if (password.length < 6) {
      throw FirebaseAuthException(
          code: 'weak-password', message: 'Password too weak');
    }

    // Simulate successful signup
    _isAuthenticated = true;
    notifyListeners();
    return null; // Mock credential
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    // Simulate Google sign in error in test environment
    throw Exception('Google sign in not available in test environment');
  }

  @override
  Future<UserCredential?> signInWithApple() async {
    // Simulate Apple sign in error in test environment
    throw UnsupportedError('Apple Sign In is not available on this platform');
  }

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}

void main() {
  group('AuthService', () {
    late MockAuthServiceForTest authService;

    setUp(() {
      authService = MockAuthServiceForTest();
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
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('signUpWithEmailAndPassword should handle weak password', () async {
        // Test with weak password - should throw FirebaseAuthException
        expect(
          () async => await authService.signUpWithEmailAndPassword(
            'test@email.com',
            '123', // weak password
          ),
          throwsA(isA<FirebaseAuthException>()),
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
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('Google Sign In', () {
      test('signInWithGoogle should handle authentication', () async {
        // Test that Google sign in throws exception in test environment
        expect(
          () async => await authService.signInWithGoogle(),
          throwsException,
        );
      });
    });

    group('Apple Sign In', () {
      test('signInWithApple should handle authentication', () async {
        // Test that Apple sign in throws exception in test environment
        expect(
          () async => await authService.signInWithApple(),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('Sign Out', () {
      test('signOut should complete without error', () async {
        // First sign in
        await authService.signInWithEmailAndPassword(
            'test@example.com', 'password123');
        expect(authService.isAuthenticated, isTrue);

        // Then sign out
        await authService.signOut();
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
      });
    });
  });
}
