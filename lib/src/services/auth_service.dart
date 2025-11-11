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

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

class PendingJoinInfo {
  final String duoId;
  final String inviteCode;
  PendingJoinInfo(this.duoId, this.inviteCode);
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  PendingJoinInfo? pendingJoin;
  bool _isAuthLoading = true;

  AuthService() {
    // Inicializa o estado de loading como true até receber o primeiro evento.
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isAuthLoading = false;
      notifyListeners();
    });
  }

  User? get currentUser => _user;
  bool get isAuthenticated => _user != null;
  bool get isAuthLoading => _isAuthLoading;

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

      // Use popup for all platforms (web and mobile)
      // Following Firebase best practices: https://firebase.google.com/docs/auth/web/redirect-best-practices
      return await _auth.signInWithPopup(googleProvider);
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }

      // Provide user-friendly error messages
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('popup') || errorString.contains('blocked')) {
        throw Exception(
            'Popup bloqueado pelo navegador. Habilite popups para este site e tente novamente.');
      } else if (errorString.contains('missing initial state') ||
          errorString.contains('sessionstorage') ||
          errorString.contains('storage-partitioned')) {
        throw Exception(
            'SessionStorage não disponível. Tente usar modo privado do navegador ou limpar os dados do site.');
      } else {
        throw Exception('Erro ao fazer login com Google. Tente novamente.');
      }
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
      final oauthCredential = OAuthProvider('apple.com').credential(
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
