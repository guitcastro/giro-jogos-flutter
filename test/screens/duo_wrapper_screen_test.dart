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

// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/services/duo_service.dart';
import 'package:giro_jogos/src/models/duo.dart';
import '../fakes/fake_duo_service.dart';
import '../test_helpers.dart';
import 'mock_duo_wrapper_screen.dart';
import 'package:giro_jogos/src/screens/duo/no_duo_screen.dart';
import 'package:giro_jogos/src/services/join_duo_params.dart';
import 'package:giro_jogos/src/services/challenge_service.dart';
import '../fakes/fake_challenge_service.dart';

void main() {
  group('DuoWrapperScreen loading', () {
    testWidgets('exibe loading enquanto carrega o estado inicial',
        (tester) async {
      final controller = StreamController<Duo?>();
      final fakeDuoService = FakeDuoService();
      await tester.pumpWidget(MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<DuoService>.value(value: fakeDuoService),
            Provider<ChallengeService>.value(value: FakeChallengeService()),
            ChangeNotifierProvider<JoinDuoParams>(
              create: (_) => JoinDuoParams(),
            ),
          ],
          child: Builder(
            builder: (context) => MockDuoWrapperScreen(
              userId: 'userX',
              stream: controller.stream,
              scoreStream: Stream<int>.value(0),
            ),
          ),
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      controller.close();
    });
  });

  group('DuoWrapperScreen', () {
    setUpAll(() async {
      await initializeFirebaseForTesting();
    });
    testWidgets('exibe NoDuoScreen quando não há duo', (tester) async {
      final controller = StreamController<Duo?>();
      final fakeDuoService = FakeDuoService();
      await tester.pumpWidget(MaterialApp(
        home: MultiProvider(
          providers: [
            Provider<DuoService>.value(value: fakeDuoService),
            Provider<ChallengeService>.value(value: FakeChallengeService()),
            ChangeNotifierProvider<JoinDuoParams>(
              create: (_) => JoinDuoParams(),
            ),
          ],
          child: MockDuoWrapperScreen(
            userId: 'userX',
            stream: controller.stream,
            scoreStream: Stream<int>.value(0),
          ),
        ),
      ));
      controller.add(null);
      await tester.pump();
      expect(find.byType(NoDuoScreen), findsOneWidget);
      controller.close();
    });
  });
}
