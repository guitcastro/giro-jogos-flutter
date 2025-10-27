import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_wrapper.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_screen.dart';

class GiroJogosApp extends StatelessWidget {
  const GiroJogosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Giro Jogos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }

  static final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthWrapper(
          child: HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AuthWrapper(
          child: AdminScreen(),
        ),
      ),
    ],
  );
}
