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
import 'services/terms_service.dart';
import 'screens/terms/terms_wrapper.dart';

class GiroJogosApp extends StatelessWidget {
  final DuoService? duoService;
  final ChallengeService? challengeService;
  final MediaUploadService? mediaUploadService;
  final TermsService? termsService;
  const GiroJogosApp({
    super.key,
    this.duoService,
    this.challengeService,
    this.mediaUploadService,
    this.termsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DuoService>.value(value: duoService ?? DuoService()),
        Provider<ChallengeService>.value(
            value: challengeService ?? ChallengeService()),
        Provider<MediaUploadService>.value(
            value: mediaUploadService ?? MediaUploadService()),
        Provider<TermsService>.value(
            value: termsService ?? FirestoreTermsService()),
        ChangeNotifierProvider(create: (_) => JoinDuoParams()),
      ],
      child: MaterialApp.router(
        title: 'Giro Jogos',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF000408),
            onPrimary: Color(0xFFFFFFFF),
            primaryContainer: Color(0xFF2A3A42),
            onPrimaryContainer: Color(0xFFD0E4F0),
            // Use only primary palette across scheme
            secondary: Color(0xFF000408),
            onSecondary: Color(0xFFFFFFFF),
            secondaryContainer: Color(0xFF2A3A42),
            onSecondaryContainer: Color(0xFFD0E4F0),
            tertiary: Color(0xFF000408),
            onTertiary: Color(0xFFFFFFFF),
            tertiaryContainer: Color(0xFF2A3A42),
            onTertiaryContainer: Color(0xFFD0E4F0),
            error: Color(0xFF000408),
            onError: Color(0xFFFFFFFF),
            errorContainer: Color(0xFF2A3A42),
            onErrorContainer: Color(0xFFD0E4F0),
            surface: Color(0xFFF5F7F9),
            onSurface: Color(0xFF000408),
            surfaceDim: Color(0xFFD6DADD),
            surfaceBright: Color(0xFFF5F7F9),
            surfaceContainerLowest: Color(0xFFFFFFFF),
            surfaceContainerLow: Color(0xFFEFF2F4),
            surfaceContainer: Color(0xFFE9ECEF),
            surfaceContainerHigh: Color(0xFFE3E6E9),
            surfaceContainerHighest: Color(0xFFDDE0E3),
            outline: Color(0xFF6B7278),
            outlineVariant: Color(0xFFC1C7CD),
            shadow: Color(0xFF000000),
            scrim: Color(0xFF000000),
            inverseSurface: Color(0xFF2E3338),
            onInverseSurface: Color(0xFFF0F3F5),
            inversePrimary: Color(0xFF000408),
          ),
          primaryColor: const Color(0xFF000408),
          scaffoldBackgroundColor: const Color(0xFFF5F7F9),
          canvasColor: const Color(0xFFF5F7F9),
          cardColor: const Color(0xFFFFFFFF),
          dividerColor: const Color(0xFFC1C7CD),
          focusColor: const Color(0xFF000408),
          // Use subtle, semi-transparent overlays to maintain AA contrast on hover/press
          hoverColor: const Color(0x1F000408), // ~12% primary tint
          highlightColor:
              const Color(0x26000408), // ~15% primary tint for focus
          splashColor: const Color(0x33000408), // ~20% primary tint for press
          disabledColor: const Color(0xFF9BA3A9),
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
          return const AuthWrapper(
            child: TermsWrapper(child: HomeScreen()),
          );
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
          return const AuthWrapper(
            child: TermsWrapper(child: HomeScreen()),
          );
        },
      ),
    ]);
  }
}
