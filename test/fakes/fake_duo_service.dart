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

import 'package:giro_jogos/src/models/duo.dart';
import 'package:giro_jogos/src/services/duo_service.dart';

typedef DuoFuture = Future<Duo?> Function(
    {required String duoId, required String inviteCode});
typedef UserDuoFuture = Future<Duo?> Function();
typedef JoinDuoFuture = Future<void> Function({required Duo duo});

class FakeDuoService implements DuoService {
  DuoFuture? _getDuoByInviteCodeImpl;
  UserDuoFuture? _getUserDuoImpl;
  JoinDuoFuture? _joinDuoImpl;
  Stream<Duo?>? _userDuoStream;

  void stubGetDuoByInviteCode(DuoFuture impl) {
    _getDuoByInviteCodeImpl = impl;
  }

  void stubGetUserDuo(UserDuoFuture impl) {
    _getUserDuoImpl = impl;
  }

  void stubGetUserDuoStream(Stream<Duo?> stream) {
    // Ensure broadcast to allow multiple listeners in widget tree
    _userDuoStream = stream.isBroadcast ? stream : stream.asBroadcastStream();
  }

  void stubJoinDuo(JoinDuoFuture impl) {
    _joinDuoImpl = impl;
  }

  @override
  Future<Duo?> getDuoByInviteCode(
      {required String duoId, required String inviteCode}) {
    if (_getDuoByInviteCodeImpl != null) {
      return _getDuoByInviteCodeImpl!(duoId: duoId, inviteCode: inviteCode);
    }
    return Future.value(null);
  }

  @override
  Future<Duo> createDuo({required String name}) async {
    // Fake: retorna um Duo com nome e id igual ao nome
    return Duo(
      id: name,
      name: name,
      inviteCode: 'INVITE',
      participants: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String normalizeDuoId(String name) {
    // Fake: retorna o nome em minúsculo
    return name.toLowerCase();
  }

  @override
  Future<void> joinDuo({required Duo duo}) async {
    if (_joinDuoImpl != null) {
      return _joinDuoImpl!(duo: duo);
    }
    return;
  }

  @override
  Future<void> leaveDuo() async {
    // Fake: não faz nada
    return;
  }

  @override
  Future<void> deleteDuo(String duoId) async {
    // Fake: não faz nada
    return;
  }

  // Removido método duplicado getUserDuo

  @override
  Future<void> removeParticipant(
      {required String duoId, required String participantId}) async {
    // Fake: não faz nada
    return;
  }

  @override
  Stream<Duo?> getUserDuoStream() {
    final s = _userDuoStream ?? Stream<Duo?>.value(null);
    return s.isBroadcast ? s : s.asBroadcastStream();
  }

  @override
  Future<Duo?> getUserDuo() {
    if (_getUserDuoImpl != null) {
      return _getUserDuoImpl!();
    }
    return Future.value(null);
  }

  // Removido métodos duplicados joinDuo, getUserDuoStream e deleteDuo
}
