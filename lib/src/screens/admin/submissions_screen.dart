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
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../models/challenge_submission.dart';
import '../../models/challenge.dart';
import '../../models/challenge_score.dart';
import '../../services/challenge_service.dart';
import '../media/media_preview_screen.dart';
import 'score_edit_screen.dart';
import 'package:video_player/video_player.dart' as video_player;

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
                  Symbols.error,
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
                  Symbols.inbox,
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

        // Build a reactive scores map for groups to sort accordingly
        final scoreStreams = grouped
            .map((g) => challengeService.getScoreStream(
                  duoId: g.duoId,
                  challengeId: g.challengeId,
                ))
            .toList();

        return StreamBuilder<List<ChallengeScore?>>(
          stream: Rx.combineLatestList<ChallengeScore?>(scoreStreams),
          builder: (context, scoresSnap) {
            final scores = scoresSnap.data;
            final sorted = List<_SubmissionGroup>.from(grouped);
            if (scores != null && scores.length == sorted.length) {
              sorted.sort((a, b) {
                final sa = scores[grouped.indexOf(a)];
                final sb = scores[grouped.indexOf(b)];

                final aNeedsReview =
                    sa == null || a.latestTime.isAfter(sa.updatedAt);
                final bNeedsReview =
                    sb == null || b.latestTime.isAfter(sb.updatedAt);

                if (aNeedsReview && !bNeedsReview) return -1;
                if (!aNeedsReview && bNeedsReview) return 1;
                // fallback to latest submission time desc
                return b.latestTime.compareTo(a.latestTime);
              });
            }

            return ListView.builder(
              itemCount: sorted.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final group = sorted[index];
                return _SubmissionGroupCard(group: group);
              },
            );
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
    final challengeService = Provider.of<ChallengeService>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<Challenge>(
              stream: challengeService
                  .getChallengeByIdStream(int.parse(group.challengeId)),
              builder: (context, challengeSnap) {
                final challenge = challengeSnap.data;
                return StreamBuilder<ChallengeScore?>(
                  stream: challengeService.getScoreStream(
                    duoId: group.duoId,
                    challengeId: group.challengeId,
                  ),
                  builder: (context, scoreSnap) {
                    final score = scoreSnap.data;
                    final total = challenge?.maxPoints ?? 0;
                    final duoPoints = score?.points;
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                challenge?.title ??
                                    'Desafio ${group.challengeId}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Duo: ${group.duoId}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        // Score chip (pill) with light fill, primary outline and smaller text
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            duoPoints == null
                                ? 'Sem pontuação'
                                : '$duoPoints / $total pts',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    );
                  },
                );
              },
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
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MediaPreviewScreen(submission: item),
                                ),
                              );
                            },
                            child: Image.network(
                              item.mediaUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  child: const Center(
                                    child: Icon(Symbols.broken_image, size: 48),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    MediaPreviewScreen(submission: item),
                              ),
                            );
                          },
                          child: _VideoPreview(url: item.mediaUrl),
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
                          icon: Symbols.chevron_left,
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
                          icon: Symbols.chevron_right,
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
                  _formatDate(group.latestTime),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ScoreButton(challengeId: group.challengeId, duoId: group.duoId),
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

class _ScoreButton extends StatelessWidget {
  final String challengeId;
  final String duoId;

  const _ScoreButton({required this.challengeId, required this.duoId});

  @override
  Widget build(BuildContext context) {
    final challengeService = Provider.of<ChallengeService>(context);
    return StreamBuilder(
      stream: challengeService.getScoreStream(
          duoId: duoId, challengeId: challengeId),
      builder: (context, snapshot) {
        // final hasScore = snapshot.data != null;
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size.fromHeight(40)),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ScoreEditScreen(challengeId: challengeId, duoId: duoId),
                ),
              );
            },
            icon: const Icon(Symbols.edit),
            label: const Text('Pontuação'),
          ),
        );
      },
    );
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

class _VideoPreview extends StatefulWidget {
  final String url;

  const _VideoPreview({required this.url});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  // Lazily import to avoid unnecessary dependency mention at top-level
  // but we still need the import; keeping it at file top elsewhere is okay.
  late final video_player.VideoPlayerController _controller;
  bool _initialized = false;
  bool _failed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _controller = video_player.VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );
      await _controller.initialize();
      await _controller.setVolume(0);
      await _controller.pause();
      await _controller.seekTo(Duration.zero);
      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _failed = true;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_failed) {
      return Container(
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Symbols.error, color: colorScheme.error, size: 36),
              const SizedBox(height: 8),
              const Text('Erro ao carregar prévia do vídeo'),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (!_initialized) {
      return Container(
        color: colorScheme.surfaceContainerHighest,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: video_player.VideoPlayer(_controller),
        ),
        Container(
          color: Colors.black.withValues(alpha: 0.12),
        ),
        const Center(
          child: Icon(Symbols.play_circle, size: 56, color: Colors.white),
        ),
      ],
    );
  }
}
