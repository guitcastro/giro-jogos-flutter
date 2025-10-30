import 'dart:async';
import 'package:flutter/material.dart';
import 'package:giro_jogos/src/screens/duo/no_duo_screen.dart';
import 'package:giro_jogos/src/screens/duo/pending_duo_screen.dart';
import 'package:giro_jogos/src/screens/duo/duo_screen.dart';
import 'package:giro_jogos/src/screens/home/duo_wrapper_screen.dart';
import 'package:giro_jogos/src/models/duo.dart';

class MockDuoWrapperScreen extends DuoWrapperScreen {
  final Stream<Duo?> stream;
  const MockDuoWrapperScreen({
    required super.userId,
    required super.getNames,
    required super.getScore,
    super.key,
    required this.stream,
  });

  Widget build(BuildContext context) {
    return StreamBuilder<Duo?>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return NoDuoScreen(
            onCreateDuo: (_) {},
            onJoinDuo: (_) {},
          );
        }
        final duo = snapshot.data!;
        if (duo.participants.length == 1) {
          return PendingDuoScreen(duo: duo);
        }
        return FutureBuilder(
          future: Future.wait([
            getNames(duo.participants),
            getScore(duo.id),
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
}
