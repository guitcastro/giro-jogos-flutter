import 'package:flutter/material.dart';
import '../../models/duo.dart';
import '../../services/duo_service.dart';
import '../duo/no_duo_screen.dart';
import '../duo/pending_duo_screen.dart';
import '../duo/duo_screen.dart';
import 'create_duo_screen.dart';
import 'package:provider/provider.dart';

class DuoWrapperScreen extends StatefulWidget {
  final String userId;
  final Future<List<String>> Function(List<String> ids) getNames;
  final Future<int> Function(String duoId) getScore;
  const DuoWrapperScreen({
    super.key,
    required this.userId,
    required this.getNames,
    required this.getScore,
  });

  @override
  State<DuoWrapperScreen> createState() => _DuoWrapperScreenState();
}

class _DuoWrapperScreenState extends State<DuoWrapperScreen> {
  @override
  Widget build(BuildContext context) {
    final duoService = Provider.of<DuoService>(context, listen: false);
    return StreamBuilder<Duo?>(
      stream: duoService.getUserDuoStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return NoDuoScreen(
            onCreateDuo: (ctx) => Navigator.of(ctx).push(
              MaterialPageRoute(
                builder: (_) => const CreateDuoScreen(),
              ),
            ),
            onJoinDuo: (ctx) => _showJoinDuoDialog(ctx),
          );
        }
        final duo = snapshot.data!;
        if (duo.participants.length == 1) {
          return PendingDuoScreen(duo: duo);
        }
        // Buscar nomes e pontuação
        return FutureBuilder(
          future: Future.wait([
            widget.getNames(duo.participants),
            widget.getScore(duo.id),
          ]),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final names = snap.data![0] as List<String>;
            final score = snap.data![1] as int;
            return DuoScreen(
                duo: duo, participantNames: names, totalScore: score);
          },
        );
      },
    );
  }

  void _showJoinDuoDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Entrar em Duo'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Duo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o nome do duo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Código de Convite',
                    border: OutlineInputBorder(),
                    hintText: 'Ex: ABC123',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o código de convite';
                    }
                    if (value.trim().length != 6) {
                      return 'Código deve ter 6 caracteres';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  await DuoService().joinDuo(
                    duoName: nameController.text.trim(),
                    inviteCode: codeController.text.trim().toUpperCase(),
                  );
                }
              },
              child: const Text('Entrar'),
            ),
          ],
        );
      },
    );
  }
}
