import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Note: Google Sign In 7.x simplifies authentication to use only Firebase Auth
  User? _user;

  AuthService() {
    // Check for redirect result on web startup
    if (kIsWeb) {
      _checkRedirectResult();
    }

    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Check for redirect result on web startup
  Future<void> _checkRedirectResult() async {
    if (kIsWeb) {
      try {
        final result = await _auth.getRedirectResult();
        if (result.user != null) {
          if (kDebugMode) {
            print('User signed in via redirect: ${result.user?.email}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('No redirect result or error: $e');
        }
      }
    }
  }

  User? get currentUser => _user;
  bool get isAuthenticated => _user != null;

  // Alternative Google Sign In method for sessionStorage issues
  Future<UserCredential?> signInWithGoogleAlternative() async {
    if (!kIsWeb) {
      return signInWithGoogle(); // Use normal flow for mobile
    }

    try {
      // Try to use a fresh browser window approach
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // Set custom parameters to avoid sessionStorage issues
      googleProvider.setCustomParameters({
        'prompt': 'select_account', // Force account selection
        'access_type': 'online', // Don't request offline access
      });

      return await _auth.signInWithPopup(googleProvider);
    } catch (e) {
      if (kDebugMode) {
        print('Alternative Google sign in failed: $e');
      }
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in: $e');
      }
      rethrow;
    }
  }

  Future<UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing up: $e');
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Google Sign In - Updated for google_sign_in 7.x (uses only Firebase Auth)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Create GoogleAuthProvider
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      if (kIsWeb) {
        // For web, try popup first, then redirect as fallback
        try {
          // Try popup first (preferred method)
          return await _auth.signInWithPopup(googleProvider);
        } catch (popupError) {
          if (kDebugMode) {
            print('Popup failed: $popupError');
          }

          // Check if the error is related to sessionStorage or missing initial state
          final errorString = popupError.toString().toLowerCase();
          if (errorString.contains('missing initial state') ||
              errorString.contains('sessionstorage') ||
              errorString.contains('storage-partitioned')) {
            // For sessionStorage issues, throw a specific error
            throw Exception(
                'SessionStorage não disponível. Tente usar modo privado do navegador ou limpar os dados do site.');
          }

          // For other popup issues (like blocked popups), try redirect
          try {
            await _auth.signInWithRedirect(googleProvider);
            // Note: getRedirectResult should be called after the page reloads
            return null; // Will be handled by _checkRedirectResult on next app load
          } catch (redirectError) {
            if (kDebugMode) {
              print('Redirect also failed: $redirectError');
            }

            // If both popup and redirect fail, provide helpful error
            throw Exception(
                'Não foi possível realizar login com Google. Verifique se popups estão habilitados ou tente limpar os dados do navegador.');
          }
        }
      } else {
        // For mobile platforms, use signInWithPopup directly
        // In google_sign_in 7.x, mobile also uses Firebase Auth directly
        return await _auth.signInWithPopup(googleProvider);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
      rethrow;
    }
  }

  // Apple Sign In
  Future<UserCredential?> signInWithApple() async {
    try {
      // Check if Apple Sign In is available
      if (kIsWeb) {
        throw UnsupportedError(
            'Apple Sign In is not available on web platform');
      }

      if (!Platform.isIOS && !Platform.isMacOS) {
        throw UnsupportedError(
            'Apple Sign In is only available on iOS and macOS');
      }

      // To prevent replay attacks with the credential returned from Apple, we
      // include a nonce in the credential request. When signing in with
      // Firebase, the nonce in the id token returned by Apple, is expected to
      // match the sha256 hash of the nonce.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      return await _auth.signInWithCredential(oauthCredential);
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Apple: $e');
      }
      rethrow;
    }
  }
}
