import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/challenge.dart';
import '../../services/challenge_service.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challengeService =
        Provider.of<ChallengeService>(context, listen: false);
    return Scaffold(
      body: StreamBuilder<List<Challenge>>(
        stream: challengeService.getChallengesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Erro ao carregar desafios'),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}',
                      style: const TextStyle(fontSize: 12, color: Colors.red)),
                ],
              ),
            );
          }
          final challenges = snapshot.data ?? [];
          if (challenges.isEmpty) {
            return const Center(child: Text('Nenhum desafio disponível.'));
          }
          return ListView.separated(
            itemCount: challenges.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return ListTile(
                title: Text(challenge.title),
                subtitle: Text(challenge.description),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    Text('${challenge.maxPoints} pts',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(challenge.title),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(challenge.description),
                          const SizedBox(height: 16),
                          Text('Máximo de pontos: ${challenge.maxPoints}'),
                          const SizedBox(height: 8),
                          const Text('Pontuação por usuário:'),
                          ...challenge.points.entries
                              .map((e) => Text('${e.key}: ${e.value} pts')),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Fechar'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
