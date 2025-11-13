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

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/duo.dart';
import '../../services/duo_service.dart';
import 'package:provider/provider.dart';

class PendingDuoScreen extends StatelessWidget {
  final Duo duo;
  const PendingDuoScreen({super.key, required this.duo});

  @override
  Widget build(BuildContext context) {
    final inviteText =
        'Junte-se ao meu duo "${duo.name}" no Giro Jogos!\nAcesse: https://giro-jogos.web.app/join/${duo.id}/${duo.inviteCode}';
    final colorScheme = Theme.of(context).colorScheme;
    Color fadedPrimary = colorScheme.primary.withAlpha((0.07 * 255).round());
    final duoService = Provider.of<DuoService>(context, listen: false);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty,
                  size: 64, color: Colors.blueGrey),
              const SizedBox(height: 24),
              Text(
                duo.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Convide alguém para sua dupla!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(text: inviteText),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fadedPrimary,
                    foregroundColor: colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  label: const Text('Compartilhar convite'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Desfazer dupla'),
                        content: const Text(
                            'Tem certeza que deseja desfazer a dupla? Esta ação não pode ser desfeita.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Desfazer'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      try {
                        await duoService.deleteDuo(duo.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Dupla desfeita com sucesso.')),
                          );
                          // Volta para a tela anterior, que será atualizada pelo stream
                          Navigator.of(context).maybePop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Erro ao desfazer dupla: $e')),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: fadedPrimary,
                    foregroundColor: colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  label: const Text('Desfazer dupla'),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Assim que outra pessoa entrar, vocês poderão participar dos jogos!',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
