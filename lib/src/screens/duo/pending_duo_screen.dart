import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/duo.dart';
import '../../services/duo_service.dart';

class PendingDuoScreen extends StatelessWidget {
  final Duo duo;
  const PendingDuoScreen({super.key, required this.duo});

  @override
  Widget build(BuildContext context) {
    final inviteText =
        'Junte-se ao meu duo "${duo.name}" no Giro Jogos!\nUse o código: ${duo.inviteCode}\nAcesse: https://giro-jogos.web.app/';
    return Scaffold(
      appBar: AppBar(title: const Text('Aguardando parceiro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Convide alguém para sua dupla!'),
            const SizedBox(height: 16),
            SelectableText('Código de convite: ${duo.inviteCode}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(text: inviteText),
                );
              },
              child: const Text('Compartilhar convite'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await DuoService().deleteDuo(duo.id);
                // Atualize a tela após deletar
              },
              child: const Text('Desfazer dupla'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Assim que outra pessoa entrar, vocês poderão participar dos jogos!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
