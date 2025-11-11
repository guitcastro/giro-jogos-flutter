import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_wrapper.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'package:provider/provider.dart';
import 'services/duo_service.dart';
import 'services/join_duo_params.dart';
import 'services/challenge_service.dart';

class GiroJogosApp extends StatelessWidget {
  final DuoService? duoService;
  const GiroJogosApp({super.key, this.duoService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DuoService>.value(value: duoService ?? DuoService()),
        Provider<ChallengeService>(create: (_) => ChallengeService()),
        ChangeNotifierProvider(create: (_) => JoinDuoParams()),
      ],
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

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter _buildRouter() {
    return GoRouter(navigatorKey: _rootNavigatorKey, routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const AuthWrapper(child: HomeScreen());
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AuthWrapper(
          child: AdminScreen(),
        ),
      ),
      GoRoute(
        path: '/join/:duoId/:inviteCode',
        builder: (context, state) {
          final duoId = state.pathParameters['duoId'] ?? '';
          final inviteCode = state.pathParameters['inviteCode'] ?? '';
          // Seta os params e redireciona para home sem usar context após async gap
          Future.microtask(() {
            final joinParams = Provider.of<JoinDuoParams>(
              _rootNavigatorKey.currentContext!,
              listen: false,
            );
            joinParams.setParams(duoId, inviteCode);
          });
          return const AuthWrapper(child: HomeScreen());
        },
      ),
    ]);
  }
}
