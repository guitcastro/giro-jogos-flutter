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
import 'package:giro_jogos/src/services/auth_service.dart';

/// Mock centralizado para AuthService, usando MockUser do firebase_auth_mocks
class FakeAuthService extends ChangeNotifier implements AuthService {
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

  bool _isAuthenticated;
  User? _currentUser;

  FakeAuthService({bool isAuthenticated = false, User? currentUser})
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
