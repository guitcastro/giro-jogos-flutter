import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:giro_jogos/src/screens/duo/pending_duo_screen.dart';
import 'package:giro_jogos/src/models/duo.dart';

void main() {
  group('PendingDuoScreen visual', () {
    final duo = Duo(
      id: 'duo1',
      name: 'Dupla Visual',
      inviteCode: 'ZZZZ99',
      participants: ['user1'],
      ownerId: 'user1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    testWidgets('exibe layout bonito e consistente', (tester) async {
      await tester.pumpWidget(MaterialApp(home: PendingDuoScreen(duo: duo)));
      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
      expect(find.text('Convide alguém para sua dupla!'), findsOneWidget);
      expect(find.text('Código de convite:'), findsOneWidget);
      expect(find.text('ZZZZ99'), findsOneWidget);
      expect(find.text('Compartilhar convite'), findsOneWidget);
      expect(find.text('Desfazer dupla'), findsOneWidget);
      expect(
          find.textContaining('Assim que outra pessoa entrar'), findsOneWidget);
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
      expect(find.text('Código de convite:'), findsOneWidget);
      expect(find.text('ABC123'), findsOneWidget);
      expect(find.text('Compartilhar convite'), findsOneWidget);
      expect(find.text('Desfazer dupla'), findsOneWidget);
    });
  });
}
