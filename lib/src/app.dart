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
import 'auth_wrapper.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'package:provider/provider.dart';
import 'services/duo_service.dart';
import 'services/join_duo_params.dart';
import 'services/challenge_service.dart';
import 'services/media_upload_service.dart';

class GiroJogosApp extends StatelessWidget {
  final DuoService? duoService;
  const GiroJogosApp({super.key, this.duoService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DuoService>.value(value: duoService ?? DuoService()),
        Provider<ChallengeService>(create: (_) => ChallengeService()),
        Provider<MediaUploadService>(create: (_) => MediaUploadService()),
        ChangeNotifierProvider(create: (_) => JoinDuoParams()),
      ],
      child: MaterialApp.router(
        title: 'Giro Jogos',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              // Set the predictive back transitions for Android.
              TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
              // Use zoom page transition for web to handle back gestures properly
              TargetPlatform.linux: ZoomPageTransitionsBuilder(),
              TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
              TargetPlatform.windows: ZoomPageTransitionsBuilder(),
            },
          ),
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
          requireAdmin: true,
          child: AdminHomeScreen(),
        ),
      ),
      GoRoute(
        path: '/join/:duoId/:inviteCode',
        builder: (context, state) {
          final duoId = state.pathParameters['duoId'] ?? '';
          final inviteCode = state.pathParameters['inviteCode'] ?? '';
          // Seta os params e redireciona para home sem usar context após async gap
          // Admins serão redirecionados para /admin pelo AuthWrapper
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
