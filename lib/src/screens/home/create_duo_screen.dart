import 'package:flutter/material.dart';
import '../../services/duo_service.dart';

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
      await DuoService().createDuo(name: _nameController.text.trim());
      if (!mounted) return;
      setState(() => _loading = false);
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
