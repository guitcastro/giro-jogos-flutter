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
import 'package:giro_jogos/src/screens/duo/join_duo_screen.dart';
import '../../models/duo.dart';
import '../../services/duo_service.dart';
import '../../services/join_duo_params.dart';
import '../../services/challenge_service.dart';
import '../duo/no_duo_screen.dart';
import '../duo/pending_duo_screen.dart';
import '../duo/duo_screen.dart';
import 'create_duo_screen.dart';
import 'package:provider/provider.dart';

class DuoWrapperScreen extends StatefulWidget {
  final String userId;
  const DuoWrapperScreen({
    super.key,
    required this.userId,
  });

  @override
  State<DuoWrapperScreen> createState() => _DuoWrapperScreenState();
}

class _DuoWrapperScreenState extends State<DuoWrapperScreen> {
  @override
  Widget build(BuildContext context) {
    final duoService = Provider.of<DuoService>(context, listen: false);
    final challengeService =
        Provider.of<ChallengeService>(context, listen: false);
    return Consumer<JoinDuoParams>(
      builder: (context, joinParams, _) {
        return StreamBuilder<Duo?>(
          stream: duoService.getUserDuoStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // Se há joinParams, mostrar JoinDuoScreen (passando userDuo se já existe)
            if (joinParams.hasParams) {
              return JoinDuoScreen(
                duoId: joinParams.duoId!,
                inviteCode: joinParams.inviteCode!,
                userDuo: snapshot.data,
                onJoined: () {
                  // Limpa joinParams após join
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    joinParams.clear();
                  });
                },
              );
            }
            if (!snapshot.hasData) {
              return NoDuoScreen(
                onCreateDuo: (ctx) => Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (_) => const CreateDuoScreen(),
                  ),
                ),
              );
            }
            final duo = snapshot.data!;
            if (duo.participants.length == 1) {
              return PendingDuoScreen(duo: duo);
            }
            // Usar os nomes já presentes em duo.participants
            final names = duo.participants.map((p) => p.name).toList();
            return StreamBuilder<int>(
              stream: challengeService.streamDuoTotalScore(duo.id),
              builder: (context, scoreSnap) {
                if (scoreSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
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
      },
    );
  }

  // _showJoinDuoDialog removido: agora o join é feito apenas via link de convite
}
