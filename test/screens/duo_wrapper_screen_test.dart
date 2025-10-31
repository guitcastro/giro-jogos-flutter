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

void main() {
  group('DuoWrapperScreen loading', () {
    testWidgets('exibe loading enquanto carrega o estado inicial',
        (tester) async {
      final controller = StreamController<Duo?>();
      final fakeDuoService = FakeDuoService();
      await tester.pumpWidget(MaterialApp(
        home: Provider<DuoService>.value(
          value: fakeDuoService,
          child: ChangeNotifierProvider<JoinDuoParams>(
            create: (_) => JoinDuoParams(),
            child: Builder(
              builder: (context) => MockDuoWrapperScreen(
                userId: 'userX',
                getNames: (_) async => const ['A', 'B'],
                getScore: (_) async => 0,
                stream: controller.stream,
              ),
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
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Provider<DuoService>.value(
              value: fakeDuoService,
              child: ChangeNotifierProvider<JoinDuoParams>(
                create: (_) => JoinDuoParams(),
                child: MockDuoWrapperScreen(
                  userId: 'userX',
                  getNames: (_) async => const ['A', 'B'],
                  getScore: (_) async => 0,
                  stream: controller.stream,
                ),
              ),
            ),
          ),
        ),
      );
      controller.add(null);
      await tester.pump();
      expect(find.byType(NoDuoScreen), findsOneWidget);
      controller.close();
    });
  });
}
