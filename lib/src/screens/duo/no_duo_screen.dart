import 'package:flutter/material.dart';

class NoDuoScreen extends StatelessWidget {
  final void Function(BuildContext context)? onCreateDuo;
  final void Function(BuildContext context)? onJoinDuo;
  const NoDuoScreen({super.key, this.onCreateDuo, this.onJoinDuo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.group_outlined, size: 64, color: Colors.blueGrey),
            const SizedBox(height: 24),
            const Text(
              'Você ainda não faz parte de uma dupla',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Crie uma nova dupla ou entre em uma já existente para participar dos jogos!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              onPressed: onCreateDuo != null ? () => onCreateDuo!(context) : null,
              label: const Text('Criar dupla'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 16),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.group_add),
              onPressed: onJoinDuo != null ? () => onJoinDuo!(context) : null,
              label: const Text('Juntar-se a uma dupla'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(fontSize: 16),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
