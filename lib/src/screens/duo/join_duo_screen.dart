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
import '../../services/duo_service.dart';
import '../../models/duo.dart';
import '../../services/join_duo_params.dart';

class JoinDuoScreen extends StatefulWidget {
  final String duoId;
  final String inviteCode;
  final Duo? userDuo;
  final VoidCallback? onJoined;
  const JoinDuoScreen({
    super.key,
    required this.duoId,
    required this.inviteCode,
    this.userDuo,
    this.onJoined,
  });

  @override
  State<JoinDuoScreen> createState() => _JoinDuoScreenState();
}

class _JoinDuoScreenState extends State<JoinDuoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    // Limpa o provider JoinDuoParams se existir
    try {
      final joinParams = Provider.of<JoinDuoParams>(context, listen: false);
      joinParams.clear();
    } catch (_) {}
    // Não faz pop, só limpa os parâmetros
  }

  bool _loading = false;
  String? _error;
  bool _confirming = false;

  Future<Map<String, dynamic>?> _loadDuo(BuildContext context) async {
    final duoService = Provider.of<DuoService>(context, listen: false);
    final currentDuo = widget.userDuo;
    if (currentDuo != null) {
      return {'error': 'Você já está em uma dupla.'};
    }
    try {
      final duo = await duoService.getDuoByInviteCode(
          duoId: widget.duoId, inviteCode: widget.inviteCode);
      if (duo == null) {
        return {'error': 'Dupla não encontrada.'};
      }
      if (duo.isFull) {
        return {'error': 'Esta dupla já está completa.'};
      }
      return {'duo': duo};
    } catch (e) {
      if (!mounted) return {'error': 'Erro inesperado ao carregar a dupla.'};
      return {'error': 'Erro inesperado ao carregar a dupla.'};
    }
  }

  void _onJoin(dynamic duo) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final duoService = Provider.of<DuoService>(context, listen: false);
    final joinParams = Provider.of<JoinDuoParams>(context, listen: false);
    try {
      await duoService.joinDuo(duo: duo);
      widget.onJoined?.call();
      // Limpa JoinDuoParams para DuoWrapperScreen reconstruir
      try {
        joinParams.clear();
      } catch (_) {}
      // Não faz pop
    } catch (e) {
      setState(() {
        _error = 'Erro ao entrar na dupla: $e';
        _loading = false;
      });
    }
  }

  Widget _buildContent(BuildContext context) {
    if (_loading) {
      return const CircularProgressIndicator();
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.error,
                  color: Theme.of(context).colorScheme.error, size: 64),
              const SizedBox(height: 24),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade800,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _handleBack(context),
                  child: const Text('Voltar'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (widget.userDuo != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.error,
                  color: Theme.of(context).colorScheme.error, size: 64),
              const SizedBox(height: 24),
              Text(
                'Você já está em uma dupla.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 180,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onErrorContainer,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _handleBack(context),
                  child: const Text('Voltar'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadDuo(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final data = snapshot.data!;
        if (data['error'] != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Symbols.error,
                      color: Theme.of(context).colorScheme.error, size: 64),
                  const SizedBox(height: 24),
                  Text(
                    data['error'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 180,
                    child: ElevatedButton(
                      onPressed: () => _handleBack(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onErrorContainer,
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Voltar'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final duo = data['duo'];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dupla: ${duo.name}',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Participantes:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ...duo.participants.map<Widget>(
                (p) => Text(p.name, style: const TextStyle(fontSize: 16))),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _confirming
                  ? null
                  : () {
                      setState(() => _confirming = true);
                      _onJoin(duo);
                    },
              child: const Text('Entrar nesta dupla'),
            ),
          ],
        );
      },
    );
  }
}
