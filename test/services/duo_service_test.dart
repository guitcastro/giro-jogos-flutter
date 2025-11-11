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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:giro_jogos/src/services/duo_service.dart';

void main() {
  group('DuoService unit', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late DuoService duoService;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'user1',
          email: 'user1@email.com',
        ),
        signedIn: true,
      );
      duoService = DuoService(firestore: firestore, auth: auth);
    });

    test('deleteDuo deleta o duo e remove referências dos participantes',
        () async {
      // Cria referência do duo para o usuário
      await firestore
          .collection('users')
          .doc('user1')
          .collection('duo')
          .doc('current')
          .set({
        'duoId': 'duo1',
        'inviteCode': 'ABC123',
      });
      // Cria o duo na subcoleção invites
      await firestore
          .collection('duos')
          .doc('duo1')
          .collection('invites')
          .doc('ABC123')
          .set({
        'participants': [
          {'id': 'user1', 'name': 'User 1'},
          {'id': 'user2', 'name': 'User 2'}
        ],
        'name': 'Duo Teste',
        'inviteCode': 'ABC123',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      // Cria referência do duo para outro participante
      await firestore
          .collection('users')
          .doc('user2')
          .collection('duo')
          .doc('current')
          .set({
        'duoId': 'duo1',
        'inviteCode': 'ABC123',
      });

      // Executa o deleteDuo
      await duoService.deleteDuo('duo1');

      // O documento do duo deve ser removido
      final duoDoc = await firestore
          .collection('duos')
          .doc('duo1')
          .collection('invites')
          .doc('ABC123')
          .get();
      expect(duoDoc.exists, isFalse);

      // As referências dos participantes devem ser removidas
      final user1Ref = await firestore
          .collection('users')
          .doc('user1')
          .collection('duo')
          .doc('current')
          .get();
      final user2Ref = await firestore
          .collection('users')
          .doc('user2')
          .collection('duo')
          .doc('current')
          .get();
      expect(user1Ref.exists, isFalse);
      expect(user2Ref.exists, isFalse);
    });

    test('createDuo cria e lê um duo simples', () async {
      final duoId = 'duo1';
      final duoData = {
        'participants': [
          {'id': 'user1', 'name': 'User 1'}
        ],
        'name': 'Duo Teste',
        'inviteCode': 'ABC123',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      };
      await firestore.collection('duos').doc(duoId).set(duoData);
      final snapshot = await firestore.collection('duos').doc(duoId).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot['name'], 'Duo Teste');
      expect(
        (snapshot['participants'] as List)
            .any((p) => p['id'] == 'user1' && p['name'] == 'User 1'),
        isTrue,
      );
    });

    test('getUserDuo retorna null se usuário não tem duo', () async {
      final result = await duoService.getUserDuo();
      expect(result, isNull);
    });

    test('getUserDuo retorna duo se referência existe', () async {
      // Cria referência do duo para o usuário
      await firestore
          .collection('users')
          .doc('user1')
          .collection('duo')
          .doc('current')
          .set({
        'duoId': 'duo1',
        'inviteCode': 'ABC123',
      });
      // Cria o duo na subcoleção invites
      await firestore
          .collection('duos')
          .doc('duo1')
          .collection('invites')
          .doc('ABC123')
          .set({
        'participants': [
          {'id': 'user1', 'name': 'User 1'}
        ],
        'name': 'Duo Teste',
        'inviteCode': 'ABC123',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      final result = await duoService.getUserDuo();
      expect(result, isNotNull);
      expect(result!.name, 'Duo Teste');
      expect(result.participants.map((p) => p.id), contains('user1'));
    });

    test('getDuoByInviteCode retorna null se não existe', () async {
      final result = await duoService.getDuoByInviteCode(
          duoId: 'duo1', inviteCode: 'NAOEXISTE');
      expect(result, isNull);
    });

    test('getDuoByInviteCode retorna o duo correto se existir', () async {
      // Cria o duo na subcoleção invites
      await firestore
          .collection('duos')
          .doc('duo1')
          .collection('invites')
          .doc('ABC123')
          .set({
        'participants': [
          {'id': 'user1', 'name': 'User 1'}
        ],
        'name': 'Duo Teste',
        'inviteCode': 'ABC123',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      final result = await duoService.getDuoByInviteCode(
          duoId: 'duo1', inviteCode: 'ABC123');
      expect(result, isNotNull);
      expect(result!.name, 'Duo Teste');
      expect(result.participants.map((p) => p.id), contains('user1'));
    });
  });
}
