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
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:giro_jogos/src/screens/challenge/challenge_screen.dart';
import 'package:giro_jogos/src/screens/challenge/challenge_details_screen.dart';
import 'package:giro_jogos/src/services/challenge_service.dart';
import 'package:giro_jogos/src/models/challenge.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../fakes/fake_duo_service.dart' show FakeDuoService;
import 'package:giro_jogos/src/services/duo_service.dart';
import 'package:giro_jogos/src/models/duo.dart';
import 'package:giro_jogos/src/models/challenge_submission.dart';
import 'package:image_picker/image_picker.dart';
import 'package:giro_jogos/src/models/challenge_score.dart';
import 'package:giro_jogos/src/models/leaderboard_entry.dart';

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

  // Removed getChallengeByIdStr; tests use getChallengeById(int) only.

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

  // Submission-related stubs so tests that depend on ChallengeDetailsScreen
  // or submission streams don't need Firebase. These provide simple, test-
  // friendly implementations.
  @override
  Stream<List<ChallengeSubmission>> getSubmissionsStream({
    required String challengeId,
    required String duoId,
  }) {
    // Return an empty stream by default; tests can override behavior if needed.
    return Stream.value(<ChallengeSubmission>[]);
  }

  @override
  Future<ChallengeSubmission> submitImage({
    required String challengeId,
    required String duoId,
    required XFile imageFile,
    String? description,
  }) async {
    // Return a fake submission
    return ChallengeSubmission(
      id: 'mock',
      challengeId: challengeId,
      duoId: duoId,
      uploaderUid: 'mockUser',
      mediaUrl: 'https://example.com/mock.jpg',
      mediaType: MediaType.image,
      submissionTime: DateTime.now(),
      description: description,
    );
  }

  @override
  Future<ChallengeSubmission> submitVideo({
    required String challengeId,
    required String duoId,
    required XFile videoFile,
    String? description,
  }) async {
    return ChallengeSubmission(
      id: 'mock',
      challengeId: challengeId,
      duoId: duoId,
      uploaderUid: 'mockUser',
      mediaUrl: 'https://example.com/mock.mp4',
      mediaType: MediaType.video,
      submissionTime: DateTime.now(),
      description: description,
    );
  }

  @override
  Future<void> deleteSubmission({
    required String challengeId,
    required String submissionId,
  }) async {
    return;
  }

  @override
  Stream<List<ChallengeSubmission>> getAllSubmissionsStream() {
    // Return an empty stream by default for admin functionality
    return Stream.value(<ChallengeSubmission>[]);
  }

  // Scores API stubs
  @override
  Stream<ChallengeScore?> getScoreStream({
    required String duoId,
    required String challengeId,
  }) {
    return Stream<ChallengeScore?>.value(null);
  }

  @override
  Future<ChallengeScore?> getScore({
    required String duoId,
    required String challengeId,
  }) async {
    return null;
  }

  @override
  Future<void> setScore({
    required String duoId,
    required String challengeId,
    required int points,
    required int totalPoints,
    String? comment,
    required String updatedByUid,
  }) async {
    return;
  }

  // Admin leaderboard stub
  @override
  Stream<List<LeaderboardEntry>> streamAdminLeaderboard() {
    return Stream<List<LeaderboardEntry>>.value(const <LeaderboardEntry>[]);
  }

  // Duo total score stub
  @override
  Stream<int> streamDuoTotalScore(String duoId) {
    return Stream<int>.value(0);
  }
}

void main() {
  group('ChallengeScreen', () {
    late MockChallengeService mockChallengeService;

    // We'll use FakeDuoService from test/fakes which can stub the user duo stream.

    setUp(() {
      mockChallengeService = MockChallengeService();
    });

    tearDown(() {
      mockChallengeService.dispose();
    });

    Widget createWidgetUnderTest() {
      // Provide both ChallengeService and a minimal DuoService so
      // ChallengeDetailsScreen can be navigated-to safely in tests.
      final duo = Duo(
        id: 'duo_test',
        participants: [],
        name: 'Duo Test',
        inviteCode: 'INV',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final fakeDuoService = FakeDuoService();
      fakeDuoService.stubGetUserDuoStream(Stream<Duo?>.value(duo));

      // Put providers above MaterialApp so routes pushed by Navigator
      // (ChallengeDetailsScreen) can access them as well.
      return MultiProvider(
        providers: [
          Provider<ChallengeService>.value(value: mockChallengeService),
          Provider<DuoService>.value(value: fakeDuoService),
        ],
        child: const MaterialApp(
          home: ChallengeScreen(),
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
          points: {},
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
      expect(find.byIcon(Symbols.star), findsOneWidget);
      expect(find.text('500 pts'), findsOneWidget);
    });

    testWidgets('abre detalhes ao tocar em um challenge', (tester) async {
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

      // Tap the challenge to navigate to details
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle(); // Wait for navigation animation

      // Assert: ChallengeDetailsScreen is shown with title, description and max points
      expect(find.byType(ChallengeDetailsScreen), findsOneWidget);
      // Title appears in the details screen AppBar
      expect(find.text('Desafio Teste'), findsOneWidget);
      expect(find.text('Descrição detalhada do desafio'), findsOneWidget);
      expect(find.text('Máximo: 400 pontos'), findsOneWidget);
    });

    testWidgets('fecha detalhes ao voltar', (tester) async {
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

      // Open the details screen
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // Assert details screen is open
      expect(find.byType(ChallengeDetailsScreen), findsOneWidget);

      // Act: navigate back (simulate user tapping back button)
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Assert that details screen was popped
      expect(find.byType(ChallengeDetailsScreen), findsNothing);
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

    testWidgets('tocar placeholder mostra snackbar em vez de navegar',
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

      // Tap no placeholder
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // Assert: snackbar exibido e não navega
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Esse desafio ainda não está disponível'), findsWidgets);
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
