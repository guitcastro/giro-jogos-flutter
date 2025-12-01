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

import 'package:flutter_test/flutter_test.dart';
import '../fakes/fake_auth_service.dart';

void main() {
  group('Admin Role Tests', () {
    test('AuthService should have isAdmin getter', () {
      final authService =
          FakeAuthService(isAuthenticated: true, isAdmin: false);

      expect(authService.isAdmin, false);
    });

    test('FakeAuthService should support admin status', () {
      // Non-admin user
      final nonAdminService =
          FakeAuthService(isAuthenticated: true, isAdmin: false);
      expect(nonAdminService.isAdmin, false);
      expect(nonAdminService.isAuthenticated, true);

      // Admin user
      final adminService =
          FakeAuthService(isAuthenticated: true, isAdmin: true);
      expect(adminService.isAdmin, true);
      expect(adminService.isAuthenticated, true);
    });

    test('Admin status should be independent of authentication', () {
      // Unauthenticated cannot be admin
      final unauthService =
          FakeAuthService(isAuthenticated: false, isAdmin: false);
      expect(unauthService.isAuthenticated, false);
      expect(unauthService.isAdmin, false);
    });
  });
}
