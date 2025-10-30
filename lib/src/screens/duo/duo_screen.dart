import 'package:flutter/material.dart';
import '../../models/duo.dart';

class DuoScreen extends StatelessWidget {
  final Duo duo;
  final List<String> participantNames;
  final int totalScore;
  const DuoScreen({
    super.key,
    required this.duo,
    required this.participantNames,
    required this.totalScore,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(duo.name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Dupla: ${duo.name}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            const Text('Participantes:'),
            ...participantNames.map((name) => Text(name)),
            const SizedBox(height: 16),
            Text('Pontuação total: $totalScore'),
          ],
        ),
      ),
    );
  }
}
