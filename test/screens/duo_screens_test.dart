import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:giro_jogos/src/screens/duo/no_duo_screen.dart';
import 'package:giro_jogos/src/screens/duo/pending_duo_screen.dart';
import 'package:giro_jogos/src/screens/duo/duo_screen.dart';
import 'mock_duo_wrapper_screen.dart';
import 'package:provider/provider.dart';
import '../mocks/mock_duo_service.dart';
import 'package:giro_jogos/src/services/duo_service.dart';
import '../test_helpers.dart';
import 'package:giro_jogos/src/models/duo.dart';

void main() {
  group('NoDuoScreen', () {
    testWidgets('exibe mensagem e botões para criar e juntar-se a dupla',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: NoDuoScreen()));
      expect(
          find.text('Você ainda não faz parte de uma dupla'), findsOneWidget);
      expect(
          find.text(
              'Crie uma nova dupla ou entre em uma já existente para participar dos jogos!'),
          findsOneWidget);
      expect(find.text('Criar dupla'), findsOneWidget);
      expect(find.text('Juntar-se a uma dupla'), findsOneWidget);
    });
  });

  group('PendingDuoScreen', () {
    final duo = Duo(
      id: 'duo1',
      name: 'Dupla Teste',
      inviteCode: 'ABC123',
      participants: ['user1'],
      ownerId: 'user1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    testWidgets('exibe código de convite e botões', (tester) async {
      await tester.pumpWidget(MaterialApp(home: PendingDuoScreen(duo: duo)));
      expect(find.textContaining('Código de convite: ABC123'), findsOneWidget);
      expect(find.text('Compartilhar convite'), findsOneWidget);
      expect(find.text('Desfazer dupla'), findsOneWidget);
    });
  });

  group('DuoScreen', () {
    final duo = Duo(
      id: 'duo2',
      name: 'Dupla Completa',
      inviteCode: 'XYZ789',
      participants: ['user1', 'user2'],
      ownerId: 'user1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    testWidgets('exibe nome, participantes e pontuação', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: DuoScreen(
          duo: duo,
          participantNames: const ['Alice', 'Bob'],
          totalScore: 42,
        ),
      ));
      expect(find.text('Dupla: Dupla Completa'), findsOneWidget);
      expect(find.text('Participantes:'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Pontuação total: 42'), findsOneWidget);
    });
  });

  group('DuoWrapperScreen', () {
    setUpAll(() async {
      await initializeFirebaseForTesting();
    });
    testWidgets('exibe NoDuoScreen quando não há duo', (tester) async {
      final controller = StreamController<Duo?>();
      // Mock DuoService para Provider
      final mockDuoService = MockDuoService();
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Provider<DuoService>.value(
              value: mockDuoService,
              child: MockDuoWrapperScreen(
                userId: 'userX',
                getNames: (_) async => const ['A', 'B'],
                getScore: (_) async => 0,
                stream: controller.stream,
              ),
            ),
          ),
        ),
      );
      // Emite null para simular ausência de duo
      controller.add(null);
      await tester.pump();
      expect(find.byType(NoDuoScreen), findsOneWidget);
      controller.close();
    });
  });
}
