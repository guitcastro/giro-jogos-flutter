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
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
// import 'services/join_duo_params.dart';
import 'screens/auth/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;
  final bool requireAdmin;

  const AuthWrapper({
    super.key,
    required this.child,
    this.requireAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // Exibe loading global enquanto o estado de autenticação está carregando
        if (authService.isAuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        // Se não autenticado, mostra tela de login
        if (!authService.isAuthenticated) {
          return const LoginScreen();
        }

        // Verifica permissões de admin e redireciona se necessário
        if (requireAdmin && !authService.isAdmin) {
          // Admin requerido mas usuário não é admin, redireciona para home
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/');
            }
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!requireAdmin && authService.isAdmin) {
          // Página de usuário mas usuário é admin, redireciona para admin
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/admin');
            }
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Usuário autenticado com permissões corretas, mostra a tela solicitada
        return child;
      },
    );
  }
}
