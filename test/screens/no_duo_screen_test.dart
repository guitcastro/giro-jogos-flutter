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

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:giro_jogos/src/screens/duo/no_duo_screen.dart';

void main() {
  group('NoDuoScreen', () {
    testWidgets(
        'exibe mensagem e botão para criar dupla e orientação de convite',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: NoDuoScreen(
          onCreateDuo: (_) {},
        ),
      ));
      expect(find.text('Criar dupla'), findsOneWidget);
      expect(
        find.text(
            'Ou clique em um link de convite para se juntar a uma dupla existente'),
        findsOneWidget,
      );
    });
  });
}
