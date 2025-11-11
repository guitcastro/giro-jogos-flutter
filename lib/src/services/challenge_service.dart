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

import '../models/challenge.dart';
import '../models/challenge_submission.dart';
import 'media_upload_service.dart';

class ChallengeService {
  final FirebaseFirestore _firestore;
  static const int _totalChallenges = 20;

  // Optional MediaUploadService - injected for tests to avoid initializing
  // Firebase during unit tests. If null, a real MediaUploadService will be
  // created lazily when needed.
  final MediaUploadService? _mediaService;

  ChallengeService(
      {FirebaseFirestore? firestore, MediaUploadService? mediaService})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _mediaService = mediaService;

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
    required String duoInviteCode,
    required XFile imageFile,
    String? description,
  }) async {
    return (_mediaService ?? MediaUploadService()).submitImage(
      challengeId: challengeId,
      duoId: duoId,
      duoInviteCode: duoInviteCode,
      imageFile: imageFile,
      description: description,
    );
  }

  Future<ChallengeSubmission> submitVideo({
    required String challengeId,
    required String duoId,
    required String duoInviteCode,
    required XFile videoFile,
    String? description,
  }) async {
    return (_mediaService ?? MediaUploadService()).submitVideo(
      challengeId: challengeId,
      duoId: duoId,
      duoInviteCode: duoInviteCode,
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
        .map((snapshot) => _processChallenges(snapshot))
        .handleError((error) {
      // TODO: Implement proper error logging in the future
      // For now, we let the error bubble up to be handled by the UI layer
      throw error;
    });
  }

  List<Challenge> _processChallenges(QuerySnapshot snapshot) {
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

    // Cria lista completa com placeholders para desafios inativos
    final allChallenges = <Challenge>[];
    for (int i = 1; i <= _totalChallenges; i++) {
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
}
