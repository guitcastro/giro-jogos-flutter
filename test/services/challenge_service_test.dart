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

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:giro_jogos/src/services/challenge_service.dart';

void main() {
  group('ChallengeService', () {
    late FakeFirebaseFirestore firestore;
    late ChallengeService challengeService;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      challengeService = ChallengeService(firestore: firestore);
    });

    group('getChallengesStream', () {
      test(
          'retorna lista completa de 20 challenges com placeholders para inativos',
          () async {
        // Arrange: Cria alguns challenges ativos no Firestore
        await firestore.collection('challenges').doc('1').set({
          'id': 1,
          'title': 'Desafio 1',
          'description': 'Descrição do desafio 1',
          'order': 1,
          'maxPoints': 200,
          'isActive': true,
        });
        await firestore.collection('challenges').doc('3').set({
          'id': 3,
          'title': 'Desafio 3',
          'description': 'Descrição do desafio 3',
          'order': 3,
          'maxPoints': 400,
          'isActive': true,
        });

        // Act: Obtém o stream
        final stream = challengeService.getChallengesStream();
        final challenges = await stream.first;

        // Assert: Deve retornar exatamente 20 challenges
        expect(challenges.length, equals(20));

        // Verifica challenges ativos
        expect(challenges[0].id, equals('1'));
        expect(challenges[0].title, equals('Desafio 1'));
        expect(challenges[0].maxPoints, equals(200));

        expect(challenges[2].id, equals('3'));
        expect(challenges[2].title, equals('Desafio 3'));
        expect(challenges[2].maxPoints, equals(400));

        // Verifica placeholders para challenges inativos
        expect(challenges[1].id, equals('2'));
        expect(challenges[1].title,
            equals('Esse desafio ainda não está disponível'));
        expect(challenges[1].maxPoints, equals(0));
      });

      test('ignora challenges com isActive false', () async {
        // Arrange: Cria challenges ativos e inativos
        await firestore.collection('challenges').doc('1').set({
          'id': 1,
          'title': 'Desafio 1 Ativo',
          'description': 'Descrição do desafio 1',
          'order': 1,
          'maxPoints': 200,
          'isActive': true,
        });
        await firestore.collection('challenges').doc('2').set({
          'id': 2,
          'title': 'Desafio 2 Inativo',
          'description': 'Descrição do desafio 2',
          'order': 2,
          'maxPoints': 300,
          'isActive': false,
        });

        // Act
        final stream = challengeService.getChallengesStream();
        final challenges = await stream.first;

        // Assert: Challenge 1 deve ser ativo, Challenge 2 deve ser placeholder
        expect(challenges[0].title, equals('Desafio 1 Ativo'));
        expect(challenges[0].maxPoints, equals(200));

        expect(challenges[1].title,
            equals('Esse desafio ainda não está disponível'));
        expect(challenges[1].maxPoints, equals(0));
      });
    });

    group('getChallengeById', () {
      test('retorna challenge ativo existente', () async {
        // Arrange
        await firestore.collection('challenges').doc('5').set({
          'id': 5,
          'title': 'Desafio 5',
          'description': 'Descrição do desafio 5',
          'order': 5,
          'maxPoints': 600,
          'isActive': true,
        });

        // Act
        final challenge = await challengeService.getChallengeById(5);

        // Assert
        expect(challenge, isNotNull);
        expect(challenge!.id, equals('5'));
        expect(challenge.title, equals('Desafio 5'));
        expect(challenge.maxPoints, equals(600));
      });

      test('retorna placeholder para challenge inexistente', () async {
        // Act
        final challenge = await challengeService.getChallengeById(999);

        // Assert
        expect(challenge, isNotNull);
        expect(challenge!.id, equals('999'));
        expect(
            challenge.title, equals('Esse desafio ainda não está disponível'));
        expect(challenge.maxPoints, equals(0));
      });
    });

    group('challenge submissions', () {
      test('cria submission válida sob um challenge ativo e pode ler de volta',
          () async {
        // Arrange: cria um challenge ativo e estrutura mínima de duo
        const challengeId = '10';
        const duoId = 'duo_submissions_test';
        const inviteCode = 'SUB123';
        const memberUserId = 'user_member_1';

        await firestore.collection('challenges').doc(challengeId).set({
          'id': 10,
          'title': 'Desafio Submissions',
          'description': 'Descrição teste submissions',
          'order': 10,
          'maxPoints': 100,
          'isActive': true,
        });

        await firestore
            .collection('duos')
            .doc(duoId)
            .collection('invites')
            .doc(inviteCode)
            .set({
          'participants': [
            {'id': memberUserId, 'name': 'Member User'},
          ],
          'name': 'Duo Submissions',
          'inviteCode': inviteCode,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        });

        await firestore
            .collection('users')
            .doc(memberUserId)
            .collection('duo')
            .doc('current')
            .set({
          'duoId': duoId,
          'inviteCode': inviteCode,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        });

        // Act: cria uma submission no subpath correto
        const submissionId = 'submission_valid_1';
        await firestore
            .collection('challenges')
            .doc(challengeId)
            .collection('submissions')
            .doc(submissionId)
            .set({
          'duoId': duoId,
          'duoInviteCode': inviteCode,
          'mediaUrl': 'https://example.com/photo.jpg',
          'mediaType': 'image',
          'submissionTime': DateTime.now(),
        });

        // Assert: a submission existe e possui os campos esperados
        final created = await firestore
            .collection('challenges')
            .doc(challengeId)
            .collection('submissions')
            .doc(submissionId)
            .get();

        expect(created.exists, isTrue);
        expect(created.data(), isNotNull);
        final data = created.data()!;
        expect(data['duoId'], equals(duoId));
        expect(data['duoInviteCode'], equals(inviteCode));
        expect(data['mediaUrl'], isA<String>());
        expect(data['mediaType'], anyOf(equals('image'), equals('video')));
        expect(data.containsKey('submissionTime'), isTrue);
      });

      test('stream de desafios continua funcionando com submissions criadas',
          () async {
        // Arrange: challenge ativo + submission
        await firestore.collection('challenges').doc('11').set({
          'id': 11,
          'title': 'Desafio 11',
          'description': 'Descrição',
          'order': 11,
          'maxPoints': 150,
          'isActive': true,
        });
        await firestore
            .collection('challenges')
            .doc('11')
            .collection('submissions')
            .doc('s1')
            .set({
          'duoId': 'duo1',
          'duoInviteCode': 'INV111',
          'mediaUrl': 'https://example.com/v.mp4',
          'mediaType': 'video',
          'submissionTime': DateTime.now(),
        });

        // Act
        final stream = challengeService.getChallengesStream();
        final challenges = await stream.first;

        // Assert: stream ainda retorna 20 itens com o challenge ativo em sua posição
        expect(challenges.length, equals(20));
        expect(challenges[10].id, equals('11'));
        expect(challenges[10].title, equals('Desafio 11'));
        expect(challenges[10].maxPoints, equals(150));
      });
    });
  });
}
