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

import '../../../models/leaderboard_entry.dart';

class LeaderboardRow extends StatelessWidget {
  final int placement;
  final LeaderboardEntry entry;

  const LeaderboardRow(
      {super.key, required this.placement, required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(child: Text('$placement')),
      title: Text(
        entry.duoName,
        style: theme.textTheme.titleLarge,
      ),
      subtitle: entry.members.isEmpty
          ? null
          : Text(
              entry.members.join('\n'),
              style: theme.textTheme.bodyMedium,
            ),
      // Emphasized score pill, consistent with admin style but larger
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 1.2,
          ),
        ),
        child: Text(
          '${entry.totalPoints} pts',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
