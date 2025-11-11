import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/screens/challenge/challenge_screen.dart';
import 'package:giro_jogos/src/services/challenge_service.dart';
import 'package:giro_jogos/src/models/challenge.dart';

// Implementação simplificada do ChallengeService para testes
class MockChallengeService implements ChallengeService {
  final StreamController<List<Challenge>> _streamController =
      StreamController<List<Challenge>>();
  List<Challenge> _challenges = [];
  bool _hasError = false;
  String _errorMessage = '';

  void setMockChallenges(List<Challenge> challenges) {
    _challenges = challenges;
    _streamController.add(_challenges);
  }

  void setMockError(String errorMessage) {
    _hasError = true;
    _errorMessage = errorMessage;
    _streamController.addError(errorMessage);
  }

  void clearError() {
    _hasError = false;
    _errorMessage = '';
  }

  @override
  Stream<List<Challenge>> getChallengesStream() {
    if (_hasError) {
      return Stream.error(_errorMessage);
    }
    return _streamController.stream;
  }

  @override
  Future<Challenge?> getChallengeById(int challengeId) async {
    final challenge = _challenges.firstWhere(
      (c) => c.id == challengeId.toString(),
      orElse: () => const Challenge(
        id: '0',
        title: 'Desafio não encontrado',
        description: 'Descrição não disponível',
        maxPoints: 0,
        points: {},
      ),
    );
    return challenge;
  }

  @override
  Stream<Challenge> getChallengeByIdStream(int challengeId) {
    return Stream.fromIterable([
      _challenges.firstWhere(
        (c) => c.id == challengeId.toString(),
        orElse: () => const Challenge(
          id: '0',
          title: 'Desafio não encontrado',
          description: 'Descrição não disponível',
          maxPoints: 0,
          points: {},
        ),
      )
    ]);
  }

  void dispose() {
    _streamController.close();
  }
}

void main() {
  group('ChallengeScreen', () {
    late MockChallengeService mockChallengeService;

    setUp(() {
      mockChallengeService = MockChallengeService();
    });

    tearDown(() {
      mockChallengeService.dispose();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Provider<ChallengeService>.value(
          value: mockChallengeService,
          child: const ChallengeScreen(),
        ),
      );
    }

    testWidgets('exibe loading indicator quando carregando', (tester) async {
      // Arrange: Não adiciona dados ao stream, deixa em estado de loading

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('exibe lista de challenges quando dados são carregados',
        (tester) async {
      // Arrange
      final mockChallenges = [
        const Challenge(
          id: '1',
          title: 'Desafio 1',
          description: 'Descrição do desafio 1',
          maxPoints: 200,
          points: {'user1': 150},
        ),
        const Challenge(
          id: '2',
          title: 'Desafio 2',
          description: 'Descrição do desafio 2',
          maxPoints: 300,
          points: {},
        ),
      ];

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      mockChallengeService.setMockChallenges(mockChallenges);
      await tester.pump(); // Trigger rebuild after stream update

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Desafio 1'), findsOneWidget);
      expect(find.text('Desafio 2'), findsOneWidget);
      expect(find.text('Descrição do desafio 1'), findsOneWidget);
      expect(find.text('Descrição do desafio 2'), findsOneWidget);
      expect(find.text('200 pts'), findsOneWidget);
      expect(find.text('300 pts'), findsOneWidget);
    });

    testWidgets('exibe mensagem de erro quando ocorre erro no stream',
        (tester) async {
      // Arrange
      const errorMessage = 'Erro ao conectar com o servidor';

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      mockChallengeService.setMockError(errorMessage);
      await tester.pump(); // Trigger rebuild after stream error

      // Assert
      expect(find.text('Erro ao carregar desafios'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('exibe mensagem quando lista está vazia', (tester) async {
      // Arrange
      final emptyChallenges = <Challenge>[];

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      mockChallengeService.setMockChallenges(emptyChallenges);
      await tester.pump(); // Trigger rebuild after stream update

      // Assert
      expect(find.text('Nenhum desafio disponível.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('exibe ícone de estrela e pontuação para cada challenge',
        (tester) async {
      // Arrange
      final mockChallenges = [
        const Challenge(
          id: '1',
          title: 'Desafio 1',
          description: 'Descrição do desafio 1',
          maxPoints: 500,
          points: {},
        ),
      ];

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      mockChallengeService.setMockChallenges(mockChallenges);
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('500 pts'), findsOneWidget);
    });

    testWidgets('abre dialog ao tocar em um challenge', (tester) async {
      // Arrange
      final mockChallenge = const Challenge(
        id: '1',
        title: 'Desafio Teste',
        description: 'Descrição detalhada do desafio',
        maxPoints: 400,
        points: {'user1': 350, 'user2': 200},
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      mockChallengeService.setMockChallenges([mockChallenge]);
      await tester.pump();

      // Toca no challenge
      await tester.tap(find.byType(ListTile));
      await tester.pump(); // Trigger dialog animation

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Desafio Teste'),
          findsNWidgets(2)); // Title no ListTile e no Dialog
      expect(find.text('Descrição detalhada do desafio'),
          findsNWidgets(2)); // Subtitle e no Dialog
      expect(find.text('Máximo de pontos: 400'), findsOneWidget);
      expect(find.text('Pontuação por usuário:'), findsOneWidget);
      expect(find.text('user1: 350 pts'), findsOneWidget);
      expect(find.text('user2: 200 pts'), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
    });

    testWidgets('fecha dialog ao tocar no botão fechar', (tester) async {
      // Arrange
      final mockChallenge = const Challenge(
        id: '1',
        title: 'Desafio Teste',
        description: 'Descrição do desafio',
        maxPoints: 300,
        points: {},
      );

      await tester.pumpWidget(createWidgetUnderTest());
      mockChallengeService.setMockChallenges([mockChallenge]);
      await tester.pump();

      // Abre o dialog
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // Assert que dialog está aberto
      expect(find.byType(AlertDialog), findsOneWidget);

      // Act: Fecha o dialog
      await tester.tap(find.text('Fechar'));
      await tester.pump(); // Trigger dialog close animation

      // Assert que dialog foi fechado
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('exibe separadores entre items da lista', (tester) async {
      // Arrange
      final mockChallenges = [
        const Challenge(
          id: '1',
          title: 'Desafio 1',
          description: 'Descrição 1',
          maxPoints: 200,
          points: {},
        ),
        const Challenge(
          id: '2',
          title: 'Desafio 2',
          description: 'Descrição 2',
          maxPoints: 300,
          points: {},
        ),
        const Challenge(
          id: '3',
          title: 'Desafio 3',
          description: 'Descrição 3',
          maxPoints: 400,
          points: {},
        ),
      ];

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      mockChallengeService.setMockChallenges(mockChallenges);
      await tester.pump();

      // Assert
      expect(find.byType(Divider), findsNWidgets(2)); // 3 items = 2 separadores
    });

    testWidgets('exibe challenge placeholder com pontuação zero',
        (tester) async {
      // Arrange
      final mockChallenges = [
        const Challenge(
          id: '1',
          title: 'Esse desafio ainda não está disponível',
          description:
              'Este desafio será liberado em breve. Fique atento às atualizações!',
          maxPoints: 0,
          points: {},
        ),
      ];

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      mockChallengeService.setMockChallenges(mockChallenges);
      await tester.pump();

      // Assert
      expect(
          find.text('Esse desafio ainda não está disponível'), findsOneWidget);
      expect(
          find.text(
              'Este desafio será liberado em breve. Fique atento às atualizações!'),
          findsOneWidget);
      expect(find.text('0 pts'), findsOneWidget);
    });

    testWidgets('atualiza lista quando stream emite novos dados',
        (tester) async {
      // Arrange
      final initialChallenges = [
        const Challenge(
          id: '1',
          title: 'Desafio Inicial',
          description: 'Descrição inicial',
          maxPoints: 100,
          points: {},
        ),
      ];

      final updatedChallenges = [
        const Challenge(
          id: '1',
          title: 'Desafio Atualizado',
          description: 'Descrição atualizada',
          maxPoints: 200,
          points: {},
        ),
      ];

      // Act - Estado inicial
      await tester.pumpWidget(createWidgetUnderTest());
      mockChallengeService.setMockChallenges(initialChallenges);
      await tester.pump();

      // Assert - Estado inicial
      expect(find.text('Desafio Inicial'), findsOneWidget);
      expect(find.text('100 pts'), findsOneWidget);

      // Act - Atualiza dados
      mockChallengeService.setMockChallenges(updatedChallenges);
      await tester.pump();

      // Assert - Estado atualizado
      expect(find.text('Desafio Atualizado'), findsOneWidget);
      expect(find.text('200 pts'), findsOneWidget);
      expect(find.text('Desafio Inicial'), findsNothing);
      expect(find.text('100 pts'), findsNothing);
    });
  });
}
