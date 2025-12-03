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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:giro_jogos/src/screens/duo/no_duo_screen.dart';
import 'package:giro_jogos/src/screens/duo/pending_duo_screen.dart';
import 'package:giro_jogos/src/screens/duo/duo_screen.dart';
import 'package:giro_jogos/src/screens/home/duo_wrapper_screen.dart';
import 'package:giro_jogos/src/models/duo.dart';

class MockDuoWrapperScreen extends DuoWrapperScreen {
  final Stream<Duo?> stream;
  final Stream<int> scoreStream;
  const MockDuoWrapperScreen({
    required super.userId,
    super.key,
    required this.stream,
    required this.scoreStream,
  });

  Widget build(BuildContext context) {
    return StreamBuilder<Duo?>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return NoDuoScreen(
            onCreateDuo: (_) {},
          );
        }
        final duo = snapshot.data!;
        if (duo.participants.length == 1) {
          return PendingDuoScreen(duo: duo);
        }
        final names = duo.participants.map((p) => p.name).toList();
        return StreamBuilder<int>(
          stream: scoreStream,
          builder: (context, scoreSnap) {
            final score = scoreSnap.data ?? 0;
            return DuoScreen(
              duo: duo,
              participantNames: names,
              totalScore: score,
            );
          },
        );
      },
    );
  }
}
