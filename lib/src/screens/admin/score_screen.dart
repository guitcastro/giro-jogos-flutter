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

import '../../models/leaderboard_entry.dart';
import '../../services/challenge_service.dart';
import '../leaderboard/widgets/leaderboard_row.dart';

class ScoreScreen extends StatelessWidget {
  final ChallengeService service;
  final bool isAdmin;

  const ScoreScreen({
    super.key,
    required this.service,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('[ScoreScreen] build called');
    if (!isAdmin) {
      // Evita assinar o stream sem permissão, prevenindo permission-denied
      return Scaffold(
        appBar: AppBar(title: const Text('Ranking')),
        body: const Center(
          child: Text('Você não tem permissão para ver o ranking.'),
        ),
      );
    }
    return Scaffold(
      body: StreamBuilder<List<LeaderboardEntry>>(
        stream: service.streamAdminLeaderboard(),
        builder: (context, snapshot) {
          debugPrint(
              '[ScoreScreen] state=${snapshot.connectionState} hasData=${snapshot.hasData} hasError=${snapshot.hasError}');
          if (snapshot.hasError) {
            debugPrint('[ScoreScreen] error: ${snapshot.error}');
            return Center(
              child: Text(
                'Erro ao carregar o ranking',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            debugPrint('[ScoreScreen] showing loading');
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? const <LeaderboardEntry>[];
          debugPrint('[ScoreScreen] entries length: ${entries.length}');
          // Dense ranking: 1,2,2,3
          int currentRank = 0;
          int? lastPoints;
          int index = 0;
          final rows = <Widget>[];
          for (final e in entries) {
            index += 1;
            if (lastPoints == null || e.totalPoints != lastPoints) {
              currentRank = index;
              lastPoints = e.totalPoints;
            }
            rows.add(LeaderboardRow(placement: currentRank, entry: e));
          }
          return ListView(children: rows);
        },
      ),
    );
  }
}
