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
import 'package:provider/provider.dart';
import '../../models/challenge.dart';
import '../../models/challenge_score.dart';
import '../../services/challenge_service.dart';
import '../../services/duo_service.dart';
import 'challenge_details_screen.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challengeService =
        Provider.of<ChallengeService>(context, listen: false);
    final duoService = Provider.of<DuoService>(context, listen: false);
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
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.error)),
                ],
              ),
            );
          }
          final challenges = snapshot.data ?? [];
          if (challenges.isEmpty) {
            return const Center(child: Text('Nenhum desafio disponível.'));
          }
          return StreamBuilder(
            stream: duoService.getUserDuoStream(),
            builder: (context, duoSnapshot) {
              if (duoSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final duo = duoSnapshot.data;
              final duoId = duo?.id;

              return ListView.separated(
                itemCount: challenges.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final challenge = challenges[index];

                  // Placeholders (maxPoints == 0) don't show score status
                  if (challenge.maxPoints == 0) {
                    return ListTile(
                      title: Text('${challenge.id}. ${challenge.title}'),
                      subtitle: Text(
                        challenge.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Desafio ainda não disponível.'),
                          ),
                        );
                      },
                    );
                  }

                  // If duoId is not available yet, show description only
                  if (duoId == null) {
                    return ListTile(
                      title: Text(challenge.title),
                      subtitle: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Carregando status da sua dupla...',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: const SizedBox.shrink(),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChallengeDetailsScreen(
                              challenge: challenge,
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return StreamBuilder<ChallengeScore?>(
                    stream: challengeService.getScoreStream(
                      duoId: duoId,
                      challengeId: challenge.id,
                    ),
                    builder: (context, scoreSnapshot) {
                      final score = scoreSnapshot.data;
                      final total = challenge.maxPoints;
                      final duoPoints = score?.points;
                      final label = score == null
                          ? '0/$total pts'
                          : (duoPoints == 0
                              ? 'Rejeitado'
                              : '$duoPoints / $total pts');
                      final color = score == null
                          ? Theme.of(context).colorScheme.secondary
                          : (duoPoints == 0
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary);

                      return ListTile(
                        title: Text('${challenge.id}. ${challenge.title}'),
                        subtitle: Text(
                          challenge.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: color,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            label,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChallengeDetailsScreen(
                                challenge: challenge,
                              ),
                            ),
                          );
                        },
                      );
                    },
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
