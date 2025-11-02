import 'package:flutter/material.dart';
import 'package:giro_jogos/src/screens/duo/join_duo_screen.dart';
import '../../models/duo.dart';
import '../../services/duo_service.dart';
import '../../services/join_duo_params.dart';
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
            // Buscar nomes e pontuação
            return FutureBuilder(
              future: Future.wait([
                widget.getNames(duo.participants.map((p) => p.name).toList()),
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
      },
    );
  }

  // _showJoinDuoDialog removido: agora o join é feito apenas via link de convite
}
