import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
// import 'services/join_duo_params.dart';
import 'screens/auth/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

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
        // Usuário autenticado, mostra a tela solicitada
        return child;
      },
    );
  }
}
