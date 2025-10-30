import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:giro_jogos/src/services/auth_service.dart';

/// Mock centralizado para AuthService, usando MockUser do firebase_auth_mocks
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
          String email, String password) async =>
      throw UnimplementedError();

  @override
  Future<UserCredential?> signUpWithEmailAndPassword(
          String email, String password) async =>
      throw UnimplementedError();

  @override
  Future<UserCredential?> signInWithGoogle() async =>
      throw UnimplementedError();

  @override
  Future<UserCredential?> signInWithApple() async => throw UnimplementedError();

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  void setAuthenticated(bool authenticated, [User? user]) {
    _isAuthenticated = authenticated;
    _currentUser = user;
    notifyListeners();
  }
}
