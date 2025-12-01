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
import '../../services/auth_service.dart';
import '../../services/challenge_service.dart';
import '../../models/challenge_submission.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                (user?.displayName?.isNotEmpty ?? false)
                    ? user!.displayName![0].toUpperCase()
                    : (user?.email?.isNotEmpty ?? false)
                        ? user!.email![0].toUpperCase()
                        : 'A',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await authService.signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Sair'),
              ),
            ],
          ),
        ],
      ),
      body: const _SubmissionsListView(),
    );
  }
}

class _SubmissionsListView extends StatelessWidget {
  const _SubmissionsListView();

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
                Icon(Icons.error_outline,
                    size: 48, color: Theme.of(context).colorScheme.error),
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

        final submissions = snapshot.data ?? [];

        if (submissions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma submissão encontrada',
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: submissions.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final submission = submissions[index];
            return _SubmissionCard(submission: submission);
          },
        );
      },
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final ChallengeSubmission submission;

  const _SubmissionCard({required this.submission});

  @override
  Widget build(BuildContext context) {
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
                  submission.mediaType == MediaType.image
                      ? Icons.image
                      : Icons.videocam,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Challenge ${submission.challengeId}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Duo: ${submission.duoId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (submission.mediaType == MediaType.image)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  submission.mediaUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
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
              ),
            const SizedBox(height: 12),
            if (submission.description != null &&
                submission.description!.isNotEmpty) ...[
              Text(
                submission.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enviado por: ${submission.uploaderUid.substring(0, 8)}...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  _formatDate(submission.submissionTime),
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
