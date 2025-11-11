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
import '../../services/challenge_service.dart';
import 'challenge_details_screen.dart';

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
                  // If this is a placeholder (not available yet), show a SnackBar
                  // instead of navigating to the details screen.
                  if (challenge.maxPoints == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Desafio ainda não disponível.'),
                      ),
                    );
                    return;
                  }

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
      ),
    );
  }
}
