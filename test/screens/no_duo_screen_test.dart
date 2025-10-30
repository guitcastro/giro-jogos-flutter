import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:giro_jogos/src/screens/duo/no_duo_screen.dart';

void main() {
  group('NoDuoScreen', () {
    testWidgets('exibe mensagem e botões para criar e juntar-se a dupla',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: NoDuoScreen(
          onCreateDuo: (_) {},
          onJoinDuo: (_) {},
        ),
      ));
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
}
