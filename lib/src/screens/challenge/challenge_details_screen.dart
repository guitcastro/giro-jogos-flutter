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
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import '../../models/challenge.dart';
import '../../models/challenge_submission.dart';
import '../../services/challenge_service.dart';
import '../../services/duo_service.dart';
import '../../models/duo.dart';
import '../media/media_preview_screen.dart';

class ChallengeDetailsScreen extends StatefulWidget {
  final Challenge challenge;

  const ChallengeDetailsScreen({
    super.key,
    required this.challenge,
  });

  @override
  State<ChallengeDetailsScreen> createState() => _ChallengeDetailsScreenState();
}

class _ChallengeDetailsScreenState extends State<ChallengeDetailsScreen> {
  bool _isUploading = false;
  late final ChallengeService _challengeService;

  @override
  void initState() {
    super.initState();
    // Capture ChallengeService once to avoid using BuildContext after async gaps
    _challengeService = Provider.of<ChallengeService>(
      // listen: false because we don't want rebuilds of this State when service changes
      // and accessing provider in initState with listen:false is safe.
      // This prevents lint warnings about using BuildContext across async gaps.
      context,
      listen: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final duoService = Provider.of<DuoService>(context, listen: false);
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          // User swiped right, go back
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.challenge.title),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: StreamBuilder<Duo?>(
          stream: duoService.getUserDuoStream(),
          builder: (context, duoSnapshot) {
            if (duoSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final duo = duoSnapshot.data;
            if (duo == null) {
              return const Center(
                child: Text(
                    'Você precisa estar em uma dupla para participar dos desafios.'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Challenge Description in Markdown
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Descrição do Desafio',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          MarkdownBody(
                            data: widget.challenge.description,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(fontSize: 16),
                              h1: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              h2: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              h3: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(
                                'Máximo: ${widget.challenge.maxPoints} pontos',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Upload Buttons
                  Text(
                    'Enviar Comprovação',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  // Single action button that opens the native OS picker for both
                  // images and videos using file_picker (FileType.media).
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading
                          ? null
                          : () async {
                              await _pickAnyMediaAndSubmit(duo);
                            },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Enviar mídia'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  if (_isUploading) ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Fazendo upload...'),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Submissions List
                  Text(
                    'Suas Submissões',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<ChallengeSubmission>>(
                    stream:
                        Provider.of<ChallengeService>(context, listen: false)
                            .getSubmissionsStream(
                      challengeId: widget.challenge.id,
                      duoId: duo.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              'Erro ao carregar submissões: ${snapshot.error}'),
                        );
                      }

                      final submissions = snapshot.data ?? [];
                      if (submissions.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text('Nenhuma submissão ainda.'),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: submissions.map((submission) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                submission.mediaType == MediaType.video
                                    ? Icons.play_circle_filled
                                    : Icons.image,
                                color: submission.mediaType == MediaType.video
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                              title: Text(
                                submission.mediaType == MediaType.video
                                    ? 'Vídeo'
                                    : 'Foto',
                              ),
                              subtitle: Text(
                                'Enviado em ${_formatDate(submission.submissionTime)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.share,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _shareSubmission(submission),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _deleteSubmission(submission),
                                  ),
                                ],
                              ),
                              onTap: () => _showMedia(submission),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Abre o seletor do SO que permite escolher imagens ou vídeos em uma só ação
  /// e envia a mídia apropriada usando o MediaUploadService.
  Future<void> _pickAnyMediaAndSubmit(Duo duo) async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      // Restrict picker to common image/video extensions to avoid arbitrary files
      final allowedExtensions = <String>[
        'jpg',
        'jpeg',
        'png',
        'gif',
        'heic',
        'webp',
        'mp4',
        'mov',
        'avi',
        'mkv',
        'webm',
        '3gp'
      ];

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final path = file.path;
      // On web, path may be null and bytes are provided instead; validate extension
      final ext = (file.extension ?? path?.split('.').last)?.toLowerCase();
      if (ext == null || !allowedExtensions.contains(ext)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecione apenas imagens ou vídeos.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (path == null) {
        // On web we may only have bytes; create a temporary XFile from bytes is possible
        throw Exception(
            'Seleção de arquivos pela web não está suportada neste fluxo.');
      }

      // Wrap selected file path into XFile expected by MediaUploadService
      final xfile = XFile(path);

      // Detect media type by extension (simple heuristic)
      final videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'];
      final isVideo = videoExtensions.contains(ext);

      if (isVideo) {
        await _challengeService.submitVideo(
          challengeId: widget.challenge.id,
          duoId: duo.id,
          videoFile: xfile,
        );
      } else {
        await _challengeService.submitImage(
          challengeId: widget.challenge.id,
          duoId: duo.id,
          imageFile: xfile,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _shareSubmission(ChallengeSubmission submission) async {
    try {
      // Mostra indicador de carregamento
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Preparando para compartilhar...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // Baixa o arquivo da URL remota
      final response = await http.get(Uri.parse(submission.mediaUrl));
      if (response.statusCode != 200) {
        throw Exception('Falha ao baixar o arquivo');
      }

      // Detecta o MIME type do content-type da resposta ou da URL
      String? mimeType = response.headers['content-type'];

      // Se não houver content-type, tenta extrair da URL
      if (mimeType == null || mimeType.isEmpty) {
        final uri = Uri.parse(submission.mediaUrl);
        final path = uri.path.toLowerCase();

        if (submission.mediaType == MediaType.video) {
          if (path.endsWith('.mp4')) {
            mimeType = 'video/mp4';
          } else if (path.endsWith('.mov')) {
            mimeType = 'video/quicktime';
          } else if (path.endsWith('.avi')) {
            mimeType = 'video/x-msvideo';
          } else if (path.endsWith('.mkv')) {
            mimeType = 'video/x-matroska';
          } else if (path.endsWith('.webm')) {
            mimeType = 'video/webm';
          } else {
            mimeType = 'video/mp4'; // fallback
          }
        } else {
          if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
            mimeType = 'image/jpeg';
          } else if (path.endsWith('.png')) {
            mimeType = 'image/png';
          } else if (path.endsWith('.gif')) {
            mimeType = 'image/gif';
          } else if (path.endsWith('.webp')) {
            mimeType = 'image/webp';
          } else if (path.endsWith('.heic')) {
            mimeType = 'image/heic';
          } else {
            mimeType = 'image/jpeg'; // fallback
          }
        }
      }

      // Extrai extensão do MIME type ou da URL
      String extension;
      if (mimeType.contains('jpeg')) {
        extension = 'jpg';
      } else if (mimeType.contains('png')) {
        extension = 'png';
      } else if (mimeType.contains('gif')) {
        extension = 'gif';
      } else if (mimeType.contains('webp')) {
        extension = 'webp';
      } else if (mimeType.contains('heic')) {
        extension = 'heic';
      } else if (mimeType.contains('mp4')) {
        extension = 'mp4';
      } else if (mimeType.contains('quicktime') || mimeType.contains('mov')) {
        extension = 'mov';
      } else if (mimeType.contains('avi')) {
        extension = 'avi';
      } else if (mimeType.contains('matroska') || mimeType.contains('mkv')) {
        extension = 'mkv';
      } else if (mimeType.contains('webm')) {
        extension = 'webm';
      } else {
        // Tenta extrair da URL como último recurso
        final uri = Uri.parse(submission.mediaUrl);
        final urlPath = uri.path;
        final lastDot = urlPath.lastIndexOf('.');
        if (lastDot != -1 && lastDot < urlPath.length - 1) {
          extension = urlPath.substring(lastDot + 1).split('?').first;
        } else {
          extension = submission.mediaType == MediaType.video ? 'mp4' : 'jpg';
        }
      }

      final fileName =
          'giro_jogos_${DateTime.now().millisecondsSinceEpoch}.$extension';

      // Cria XFile a partir dos bytes baixados
      final xFile = XFile.fromData(
        response.bodyBytes,
        mimeType: mimeType,
        name: fileName,
      );

      // Compartilha usando SharePlus
      final params = ShareParams(
        files: [xFile],
        fileNameOverrides: [fileName],
      );

      final result = await SharePlus.instance.share(params);

      // Remove a snackbar de carregamento
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (result.status == ShareResultStatus.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compartilhado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteSubmission(ChallengeSubmission submission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir esta submissão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              navigator.pop();
              try {
                await _challengeService.deleteSubmission(
                  challengeId: widget.challenge.id,
                  submissionId: submission.id,
                );
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Submissão excluída com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Erro ao excluir: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMedia(ChallengeSubmission submission) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaPreviewScreen(submission: submission),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
