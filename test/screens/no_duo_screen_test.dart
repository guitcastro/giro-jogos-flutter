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
