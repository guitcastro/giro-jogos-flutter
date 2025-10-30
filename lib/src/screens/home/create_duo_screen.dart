import 'package:flutter/material.dart';
import '../../services/duo_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../models/duo.dart';

class CreateDuoScreen extends StatefulWidget {
  const CreateDuoScreen({super.key});

  @override
  State<CreateDuoScreen> createState() => _CreateDuoScreenState();
}

class _CreateDuoScreenState extends State<CreateDuoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createDuo() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final Duo duo =
          await DuoService().createDuo(name: _nameController.text.trim());
      if (!mounted) return;
      setState(() => _loading = false);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Dupla criada!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Compartilhe o código de convite com seu parceiro:'),
                const SizedBox(height: 12),
                SelectableText(
                  duo.inviteCode,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copiar código',
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: duo.inviteCode));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Código copiado!')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      tooltip: 'Compartilhar',
                      onPressed: () {
                        final inviteText =
                            'Junte-se ao meu duo "${duo.name}" no Giro Jogos!\nUse o código: ${duo.inviteCode}\nAcesse: https://giro-jogos.web.app/';
                        SharePlus.instance.share(
                          ShareParams(text: inviteText),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      if (!mounted) return;
      // Pop até sair da tela de criação e voltar para a Home (DuoWrapperScreen)
      Navigator.of(context).pop();
      // O PendingDuoScreen será exibido automaticamente pelo DuoWrapperScreen via stream
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar dupla: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Dupla'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Duo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  if (value.trim().length > 50) {
                    return 'Nome muito longo (máximo 50 caracteres)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _createDuo,
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Criar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
