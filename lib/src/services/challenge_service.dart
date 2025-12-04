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
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';

import '../models/challenge.dart';
import '../models/challenge_submission.dart';
import '../models/challenge_score.dart';
import 'media_upload_service.dart';
import 'duo_repository.dart';
import '../models/leaderboard_entry.dart';

class ChallengeService {
  final FirebaseFirestore _firestore;
  // Optional MediaUploadService - injected for tests to avoid initializing
  // Firebase during unit tests. If null, a real MediaUploadService will be
  // created lazily when needed.
  final MediaUploadService? _mediaService;
  final DuoRepository? _duoRepository;

  ChallengeService({
    FirebaseFirestore? firestore,
    MediaUploadService? mediaService,
    DuoRepository? duoRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _mediaService = mediaService,
        _duoRepository = duoRepository;

  /// Stream de submissões para um desafio por dupla
  Stream<List<ChallengeSubmission>> getSubmissionsStream({
    required String challengeId,
    required String duoId,
  }) {
    return (_mediaService ?? MediaUploadService()).getSubmissionsStream(
      challengeId: challengeId,
      duoId: duoId,
    );
  }

  Future<ChallengeSubmission> submitImage({
    required String challengeId,
    required String duoId,
    required XFile imageFile,
    String? description,
  }) async {
    return (_mediaService ?? MediaUploadService()).submitImage(
      challengeId: challengeId,
      duoId: duoId,
      imageFile: imageFile,
      description: description,
    );
  }

  Future<ChallengeSubmission> submitVideo({
    required String challengeId,
    required String duoId,
    required XFile videoFile,
    String? description,
  }) async {
    return (_mediaService ?? MediaUploadService()).submitVideo(
      challengeId: challengeId,
      duoId: duoId,
      videoFile: videoFile,
      description: description,
    );
  }

  Future<void> deleteSubmission({
    required String challengeId,
    required String submissionId,
  }) async {
    return (_mediaService ?? MediaUploadService()).deleteSubmission(
      challengeId: challengeId,
      submissionId: submissionId,
    );
  }

  Stream<List<Challenge>> getChallengesStream() {
    return _firestore
        .collection('challenges')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async => await _processChallenges(snapshot))
        .handleError((error) {
      throw error;
    });
  }

  /// Busca o total de desafios configurado no Firestore
  Future<int> _getTotalChallenges() async {
    try {
      final doc =
          await _firestore.collection('settings').doc('challenges').get();
      if (doc.exists && doc.data()?['totalChallenges'] is int) {
        return doc.data()!['totalChallenges'] as int;
      }
      // Valor padrão se não existir no Firestore
      return 27;
    } catch (e) {
      debugPrint('[ChallengeService] Error fetching totalChallenges: $e');
      return 27;
    }
  }

  /// Scores API
  DocumentReference<Map<String, dynamic>> _scoreDocRef({
    required String duoId,
    required String challengeId,
  }) {
    return _firestore
        .collection('scores')
        .doc(duoId)
        .collection('challenges')
        .doc(challengeId);
  }

  Stream<ChallengeScore?> getScoreStream({
    required String duoId,
    required String challengeId,
  }) {
    return _scoreDocRef(duoId: duoId, challengeId: challengeId)
        .snapshots()
        .map((doc) => doc.exists ? ChallengeScore.fromFirestore(doc) : null);
  }

  Future<ChallengeScore?> getScore({
    required String duoId,
    required String challengeId,
  }) async {
    final doc =
        await _scoreDocRef(duoId: duoId, challengeId: challengeId).get();
    if (!doc.exists) return null;
    return ChallengeScore.fromFirestore(doc);
  }

  Future<void> setScore({
    required String duoId,
    required String challengeId,
    required int points,
    required int totalPoints,
    String? comment,
    required String updatedByUid,
  }) async {
    final data = ChallengeScore(
      duoId: duoId,
      challengeId: challengeId,
      points: points,
      totalPoints: totalPoints,
      comment: comment,
      updatedByUid: updatedByUid,
      updatedAt: DateTime.now(),
    ).toMap();

    await _scoreDocRef(duoId: duoId, challengeId: challengeId).set(data);
  }

  /// Duo total score: sums points across all challenges for a given duo
  Stream<int> streamDuoTotalScore(String duoId) {
    final challengesColl =
        _firestore.collection('scores').doc(duoId).collection('challenges');

    return challengesColl.snapshots().map((snapshot) {
      var total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final points = data['points'];
        if (points is num) {
          total += points.toInt();
        }
      }
      return total;
    }).handleError((error, stack) {
      debugPrint('[ChallengeService] streamDuoTotalScore error: $error');
    });
  }

  /// Admin leaderboard: aggregates scores across all duos and challenges
  Stream<List<LeaderboardEntry>> streamAdminLeaderboard() {
    // Use collectionGroup over 'challenges' filtering by duoId
    return _firestore
        .collectionGroup('challenges')
        .where('duoId', isGreaterThan: '')
        .snapshots()
        .asyncMap((snapshot) async {
      debugPrint(
          '[ChallengeService] leaderboard docs: ${snapshot.docs.length}');
      final scores = <ChallengeScore>[];
      for (final d in snapshot.docs) {
        try {
          scores.add(ChallengeScore.fromFirestore(d));
        } catch (e, st) {
          debugPrint('[ChallengeService] parse failed ${d.reference.path}: $e');
          debugPrint('$st');
        }
      }
      final totals = <String, int>{};
      for (final s in scores) {
        totals[s.duoId] = (totals[s.duoId] ?? 0) + s.points;
      }
      final entries = <LeaderboardEntry>[];
      for (final entry in totals.entries) {
        DuoInfo? info;
        try {
          info =
              await (_duoRepository ?? DuoRepository()).getDuoInfo(entry.key);
        } catch (_) {}
        entries.add(LeaderboardEntry(
          duoId: entry.key,
          duoName: info?.name ?? entry.key,
          members: info?.members ?? const <String>[],
          totalPoints: entry.value,
          updatedAt: DateTime.now(),
        ));
      }
      entries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
      return entries;
    });
  }

  Future<List<Challenge>> _processChallenges(QuerySnapshot snapshot) async {
    final activeChallenges = <Challenge>[];
    final activeIds = <int>{};

    // Processa os desafios ativos do Firestore (já filtrados pela query WHERE)
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final challenge = Challenge.fromMap(data, doc.id);
      activeChallenges.add(challenge);
      activeIds.add(int.parse(challenge.id));
    }

    // Ordena os desafios ativos por ID (que corresponde à order)
    activeChallenges.sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));

    // Busca o total de desafios do Firestore
    final totalChallenges = await _getTotalChallenges();

    // Cria lista completa com placeholders para desafios inativos
    final allChallenges = <Challenge>[];
    for (int i = 1; i <= totalChallenges; i++) {
      if (activeIds.contains(i)) {
        // Adiciona o desafio ativo
        final activeChallenge =
            activeChallenges.firstWhere((c) => int.parse(c.id) == i);
        allChallenges.add(activeChallenge);
      } else {
        // Adiciona placeholder para desafio inativo
        allChallenges.add(_createInactiveChallenge(i));
      }
    }

    return allChallenges;
  }

  Challenge _createInactiveChallenge(int id) {
    return Challenge(
      id: id.toString(),
      title: 'Esse desafio ainda não está disponível',
      description:
          'Este desafio será liberado em breve. Fique atento às atualizações!',
      maxPoints: 0,
      points: <String, int>{},
    );
  }

  /// Busca um desafio específico pelo ID
  Future<Challenge?> getChallengeById(int challengeId) async {
    try {
      final doc = await _firestore
          .collection('challenges')
          .doc(challengeId.toString())
          .get();

      if (doc.exists && doc.data()?['isActive'] == true) {
        return Challenge.fromMap(doc.data()!, doc.id);
      } else {
        return _createInactiveChallenge(challengeId);
      }
    } catch (e) {
      // Se houver erro ou desafio não existir, retorna placeholder
      return _createInactiveChallenge(challengeId);
    }
  }

  /// Stream para um desafio específico
  Stream<Challenge> getChallengeByIdStream(int challengeId) {
    return _firestore
        .collection('challenges')
        .doc(challengeId.toString())
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data()?['isActive'] == true) {
        return Challenge.fromMap(doc.data()!, doc.id);
      } else {
        return _createInactiveChallenge(challengeId);
      }
    });
  }

  /// Stream de todas as submissões de todos os challenges (para admin)
  Stream<List<ChallengeSubmission>> getAllSubmissionsStream() {
    // Observa a lista de challenges e reconstrói a combinação dos streams
    // de submissions sempre que a lista de challenges mudar.
    return _firestore.collection('challenges').snapshots().switchMap((snap) {
      final challengeIds = snap.docs.map((d) => d.id).toList();

      if (challengeIds.isEmpty) {
        return Stream.value(<ChallengeSubmission>[]);
      }

      final perChallengeStreams = challengeIds.map((id) {
        return _firestore
            .collection('challenges')
            .doc(id)
            .collection('submissions')
            .orderBy('submissionTime', descending: true)
            .snapshots()
            .map((submissionSnap) => submissionSnap.docs
                .map((doc) => ChallengeSubmission.fromFirestore(doc))
                .toList());
      }).toList();

      return Rx.combineLatestList<List<ChallengeSubmission>>(
              perChallengeStreams)
          .map((lists) {
        final merged = <ChallengeSubmission>[];
        for (final list in lists) {
          merged.addAll(list);
        }
        // Ordena por data de submissão (desc)
        merged.sort((a, b) => b.submissionTime.compareTo(a.submissionTime));
        return merged;
      });
    });
  }
}
