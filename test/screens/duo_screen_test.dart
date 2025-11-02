import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:giro_jogos/src/screens/duo/duo_screen.dart';
import 'package:giro_jogos/src/models/duo.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/services/duo_service.dart';
import '../fakes/fake_duo_service.dart';

void main() {
  group('DuoScreen', () {
    final duo = Duo(
      id: 'duo2',
      name: 'Dupla Completa',
      inviteCode: 'XYZ789',
      participants: const [
        DuoParticipant(id: 'user1', name: 'Alice'),
        DuoParticipant(id: 'user2', name: 'Bob'),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    testWidgets('exibe nome, participantes e pontuação', (tester) async {
      // Provider fake para evitar erro de contexto
      await tester.pumpWidget(MaterialApp(
        home: Provider<DuoService>.value(
          value: FakeDuoService(),
          child: DuoScreen(
            duo: duo,
            participantNames: const ['Alice', 'Bob'],
            totalScore: 42,
          ),
        ),
      ));
      expect(find.text('Dupla: Dupla Completa'), findsOneWidget);
      expect(find.text('Participantes:'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Pontuação total: 42'), findsOneWidget);
    });
  });
}
