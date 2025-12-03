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
