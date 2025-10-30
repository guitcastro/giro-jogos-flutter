import 'package:giro_jogos/src/services/duo_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:giro_jogos/src/screens/duo/pending_duo_screen.dart';
import 'package:giro_jogos/src/models/duo.dart';

import '../fakes/fake_duo_service.dart' show FakeDuoService;

void main() {
  group('PendingDuoScreen desfazer grupo', () {
    final duo = Duo(
      id: 'duo1',
      name: 'Dupla Teste',
      inviteCode: 'ABC123',
      participants: ['user1'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('fluxo de desfazer dupla mostra diálogo e executa ação',
        (tester) async {
      final fakeService = FakeDuoService();

      await tester.pumpWidget(
        Provider<DuoService>.value(
          value: fakeService,
          child: MaterialApp(home: PendingDuoScreen(duo: duo)),
        ),
      );
      // Toca no botão "Desfazer dupla"
      await tester.tap(find.text('Desfazer dupla'));
      await tester.pumpAndSettle();
      // Deve mostrar o diálogo de confirmação
      expect(find.text('Desfazer dupla'), findsNWidgets(2)); // botão e diálogo
      expect(
          find.text(
              'Tem certeza que deseja desfazer a dupla? Esta ação não pode ser desfeita.'),
          findsOneWidget);
      // Confirma a ação
      await tester.tap(find.widgetWithText(ElevatedButton, 'Desfazer'));
      await tester.pumpAndSettle();
      // Não é possível verificar chamada em Fake, mas não deve lançar erro
    });
  });
  group('PendingDuoScreen visual', () {
    final duo = Duo(
      id: 'duo1',
      name: 'Dupla Visual',
      inviteCode: 'ZZZZ99',
      participants: ['user1'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    testWidgets('exibe layout bonito e consistente', (tester) async {
      final fakeService = FakeDuoService();
      await tester.pumpWidget(
        Provider<DuoService>.value(
          value: fakeService,
          child: MaterialApp(home: PendingDuoScreen(duo: duo)),
        ),
      );
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    testWidgets('exibe código de convite e botões', (tester) async {
      final fakeService = FakeDuoService();
      await tester.pumpWidget(
        Provider<DuoService>.value(
          value: fakeService,
          child: MaterialApp(home: PendingDuoScreen(duo: duo)),
        ),
      );
      expect(find.text('Código de convite:'), findsOneWidget);
      expect(find.text('ABC123'), findsOneWidget);
      expect(find.text('Compartilhar convite'), findsOneWidget);
      expect(find.text('Desfazer dupla'), findsOneWidget);
    });
  });
}
