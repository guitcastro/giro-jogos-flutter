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

import 'package:giro_jogos/src/services/duo_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:giro_jogos/src/screens/duo/pending_duo_screen.dart';
import 'package:giro_jogos/src/models/duo.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../fakes/fake_duo_service.dart' show FakeDuoService;

void main() {
  group('PendingDuoScreen desfazer grupo', () {
    final duo = Duo(
      id: 'duo1',
      name: 'Dupla Teste',
      inviteCode: 'ABC123',
      participants: [const DuoParticipant(id: 'user1', name: 'User 1')],
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
      participants: [const DuoParticipant(id: 'user1', name: 'User 1')],
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
      expect(find.byIcon(Symbols.hourglass_empty), findsOneWidget);
      expect(find.text('Convide alguém para sua dupla!'), findsOneWidget);
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
      participants: [const DuoParticipant(id: 'user1', name: 'User 1')],
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
      expect(find.text('Compartilhar convite'), findsOneWidget);
      expect(find.text('Desfazer dupla'), findsOneWidget);
    });
  });
}
