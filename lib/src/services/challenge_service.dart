import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/challenge.dart';

class ChallengeService {
  final FirebaseFirestore _firestore;
  static const int _totalChallenges = 20;

  ChallengeService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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
