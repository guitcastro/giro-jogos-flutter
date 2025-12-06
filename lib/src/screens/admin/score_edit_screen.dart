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

/*
 * This file is part of Giro Jogos.
 */

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../models/challenge.dart';
import '../../models/challenge_score.dart';
import '../../services/challenge_service.dart';

class ScoreEditScreen extends StatefulWidget {
  final String challengeId;
  final String duoId;

  const ScoreEditScreen(
      {super.key, required this.challengeId, required this.duoId});

  @override
  State<ScoreEditScreen> createState() => _ScoreEditScreenState();
}

class _ScoreEditScreenState extends State<ScoreEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pointsCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  Challenge? _challenge;
  bool _saving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  Future<void> _loadChallenge() async {
    final challengeService =
        Provider.of<ChallengeService>(context, listen: false);
    final challenge =
        await challengeService.getChallengeById(int.parse(widget.challengeId));
    if (mounted) {
      setState(() {
        _challenge = challenge;
      });
    }
  }

  void _initializeControllers(ChallengeScore? score) {
    if (!_initialized && score != null) {
      _pointsCtrl.text = score.points.toString();
      _commentCtrl.text = score.comment ?? '';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _pointsCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challengeService =
        Provider.of<ChallengeService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pontuação do desafio'),
      ),
      body: _challenge == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<ChallengeScore?>(
                stream: challengeService.getScoreStream(
                  duoId: widget.duoId,
                  challengeId: widget.challengeId,
                ),
                builder: (context, scoreSnap) {
                  if (scoreSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final existing = scoreSnap.data;
                  _initializeControllers(existing);

                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerLowest,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _challenge!.title,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _challenge!.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Symbols.star, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text(
                              'Pontos totais do desafio: ${_challenge!.maxPoints}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _pointsCtrl,
                          keyboardType: TextInputType.number,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            labelText: 'Pontos atribuídos',
                            hintText: 'Quantos pontos deseja atribuir?',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Informe os pontos atribuídos';
                            }
                            final parsed = int.tryParse(value.trim());
                            if (parsed == null) {
                              return 'Informe um número válido';
                            }
                            if (parsed < 0 || parsed > _challenge!.maxPoints) {
                              return 'Deve estar entre 0 e ${_challenge!.maxPoints}';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _commentCtrl,
                          maxLines: 3,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            labelText: 'Comentário (opcional)',
                            hintText: 'Adicione um comentário para a dupla',
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _saving
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    setState(() => _saving = true);
                                    try {
                                      final navigator = Navigator.of(context);
                                      final points =
                                          int.parse(_pointsCtrl.text.trim());
                                      // TODO: replace with real admin uid from auth service if available
                                      const adminUid = 'admin';
                                      await challengeService.setScore(
                                        duoId: widget.duoId,
                                        challengeId: widget.challengeId,
                                        points: points,
                                        totalPoints: _challenge!.maxPoints,
                                        comment:
                                            _commentCtrl.text.trim().isEmpty
                                                ? null
                                                : _commentCtrl.text.trim(),
                                        updatedByUid: adminUid,
                                      );
                                      if (mounted) {
                                        navigator.pop(true);
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() => _saving = false);
                                      }
                                    }
                                  },
                            child: Text(existing == null
                                ? 'Salvar pontuação'
                                : 'Atualizar pontuação'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
