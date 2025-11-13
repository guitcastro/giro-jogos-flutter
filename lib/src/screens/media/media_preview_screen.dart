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
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/challenge_submission.dart';
import '../../widgets/video_player_widget.dart';

class MediaPreviewScreen extends StatelessWidget {
  final ChallengeSubmission submission;

  const MediaPreviewScreen({
    super.key,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              submission.mediaType == MediaType.video ? 'Vídeo' : 'Foto',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Enviado em ${_formatDate(submission.submissionTime)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Abrir no navegador',
            onPressed: () => _openInBrowser(context),
          ),
        ],
      ),
      body: Center(
        child: submission.mediaType == MediaType.video
            ? VideoPlayerWidget(videoUrl: submission.mediaUrl)
            : InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: submission.mediaUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Carregando imagem...',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    // Log the error for debugging
                    debugPrint('Error loading image: $error');
                    debugPrint('URL: $url');

                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao carregar imagem',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              style: TextStyle(
                                color: colorScheme.onSurface.withAlpha(179),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              url,
                              style: TextStyle(
                                color: colorScheme.onSurface.withAlpha(137),
                                fontFamily: 'monospace',
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _openInBrowser(context),
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Abrir no navegador'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                // Clear cache and try to reload
                                CachedNetworkImage.evictFromCache(url);
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => MediaPreviewScreen(
                                        submission: submission),
                                  ),
                                );
                              },
                              child: const Text(
                                'Limpar cache e tentar novamente',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Future<void> _openInBrowser(BuildContext context) async {
    final url = Uri.parse(submission.mediaUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
