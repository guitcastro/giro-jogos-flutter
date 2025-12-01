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

import '../../models/challenge_submission.dart';
import '../../services/challenge_service.dart';

class SubmissionsScreen extends StatelessWidget {
  const SubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challengeService = Provider.of<ChallengeService>(context);

    return StreamBuilder<List<ChallengeSubmission>>(
      stream: challengeService.getAllSubmissionsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar submissões',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final submissions = snapshot.data ?? <ChallengeSubmission>[];
        if (submissions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma submissão encontrada',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        final grouped = _groupSubmissions(submissions);

        return ListView.builder(
          itemCount: grouped.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final group = grouped[index];
            return _SubmissionGroupCard(group: group);
          },
        );
      },
    );
  }
}

class _SubmissionGroup {
  final String challengeId;
  final String duoId;
  final List<ChallengeSubmission> submissions;
  final DateTime latestTime;

  const _SubmissionGroup({
    required this.challengeId,
    required this.duoId,
    required this.submissions,
    required this.latestTime,
  });
}

List<_SubmissionGroup> _groupSubmissions(
  List<ChallengeSubmission> submissions,
) {
  final map = <String, List<ChallengeSubmission>>{};

  for (final s in submissions) {
    final key = '${s.challengeId}|${s.duoId}';
    map.putIfAbsent(key, () => <ChallengeSubmission>[]).add(s);
  }

  final groups = <_SubmissionGroup>[];
  map.forEach((key, list) {
    list.sort((a, b) => b.submissionTime.compareTo(a.submissionTime));
    final parts = key.split('|');
    groups.add(
      _SubmissionGroup(
        challengeId: parts[0],
        duoId: parts[1],
        submissions: List<ChallengeSubmission>.unmodifiable(list),
        latestTime: list.first.submissionTime,
      ),
    );
  });

  groups.sort((a, b) => b.latestTime.compareTo(a.latestTime));
  return groups;
}

class _SubmissionGroupCard extends StatefulWidget {
  final _SubmissionGroup group;

  const _SubmissionGroupCard({required this.group});

  @override
  State<_SubmissionGroupCard> createState() => _SubmissionGroupCardState();
}

class _SubmissionGroupCardState extends State<_SubmissionGroupCard> {
  late final PageController _controller;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goPrevious() {
    if (_pageIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _goNext() {
    if (_pageIndex < widget.group.submissions.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final latest = group.submissions.first;
    final leadingIcon =
        latest.mediaType == MediaType.image ? Icons.image : Icons.videocam;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  leadingIcon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Challenge ${group.challengeId}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Duo: ${group.duoId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${group.submissions.length} mídias',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: group.submissions.length,
                      onPageChanged: (i) => setState(() => _pageIndex = i),
                      itemBuilder: (context, index) {
                        final item = group.submissions[index];
                        if (item.mediaType == MediaType.image) {
                          return Image.network(
                            item.mediaUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 48),
                                ),
                              );
                            },
                          );
                        }
                        return Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_circle_outline, size: 48),
                                SizedBox(height: 8),
                                Text('Vídeo'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (group.submissions.length > 1) ...[
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _NavButton(
                          icon: Icons.chevron_left,
                          onTap: _goPrevious,
                          enabled: _pageIndex > 0,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _NavButton(
                          icon: Icons.chevron_right,
                          onTap: _goNext,
                          enabled: _pageIndex < group.submissions.length - 1,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(group.submissions.length, (i) {
                          final bool active = i == _pageIndex;
                          return Container(
                            width: active ? 8 : 6,
                            height: active ? 8 : 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.5),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (group.submissions.length == 1 &&
                latest.description != null &&
                latest.description!.isNotEmpty) ...[
              Text(
                latest.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enviado por: ${latest.uploaderUid.substring(0, 8)}...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  _formatDate(group.latestTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Agora';
    }
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface.withValues(alpha: 0.85);
    final fg = enabled
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: fg, size: 22),
      ),
    );
  }
}
