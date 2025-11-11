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
  });
}
