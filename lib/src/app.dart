import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_wrapper.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'package:provider/provider.dart';
import 'services/duo_service.dart';

class GiroJogosApp extends StatelessWidget {
  final DuoService? duoService;
  const GiroJogosApp({super.key, this.duoService});

  @override
  Widget build(BuildContext context) {
    return Provider<DuoService>.value(
      value: duoService ?? DuoService(),
      child: MaterialApp.router(
        title: 'Giro Jogos',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: _buildRouter(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  static GoRouter _buildRouter() {
    return GoRouter(
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
}
