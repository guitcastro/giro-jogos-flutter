import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // If user is not authenticated, show login screen
        if (!authService.isAuthenticated) {
          return const LoginScreen();
        }

        // User is authenticated, show the requested screen
        return child;
      },
    );
  }
}
