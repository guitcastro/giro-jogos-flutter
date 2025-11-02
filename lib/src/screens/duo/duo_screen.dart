import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/duo.dart';
import '../../services/duo_service.dart';

class DuoScreen extends StatelessWidget {
  final Duo duo;
  final List<String> participantNames;
  final int totalScore;

  const DuoScreen({
    super.key,
    required this.duo,
    required this.participantNames,
    required this.totalScore,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fadedPrimary = colorScheme.primary.withAlpha((0.07 * 255).round());
    final duoService = Provider.of<DuoService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          duo.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.groups, size: 64, color: Colors.deepPurple),
              const SizedBox(height: 24),
              Text(
                'Dupla: ${duo.name}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: fadedPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Participantes:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ...participantNames.map((name) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 18, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Text(name, style: const TextStyle(fontSize: 15)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events,
                        color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Pontuação total: $totalScore',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair da dupla'),
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
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sair da dupla'),
                        content:
                            const Text('Tem certeza que deseja sair da dupla?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Sair'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      try {
                        await duoService.leaveDuo();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Você saiu da dupla.')),
                          );
                          Navigator.of(context).maybePop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Erro ao sair da dupla: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
