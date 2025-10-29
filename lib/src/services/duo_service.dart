import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/duo.dart';

class DuoService {
  static const String _collection = 'duos';
  static const String _userDuosSubcollection = 'duos';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Gerar código de convite único
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
          6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // Verificar se o código de convite já existe
  Future<bool> _isInviteCodeUnique(String code) async {
    final query = await _firestore
        .collection(_collection)
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();

    return query.docs.isEmpty;
  }

  // Gerar código de convite único
  Future<String> _generateUniqueInviteCode() async {
    String code;
    bool isUnique = false;
    int attempts = 0;
    const maxAttempts = 10;

    do {
      code = _generateInviteCode();
      isUnique = await _isInviteCodeUnique(code);
      attempts++;
    } while (!isUnique && attempts < maxAttempts);

    if (!isUnique) {
      throw Exception(
          'Não foi possível gerar um código único após $maxAttempts tentativas');
    }

    return code;
  }

  // Criar um novo duo
  Future<Duo> createDuo({
    required String name,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    // Verificar se o usuário já está em algum duo
    final userDuos = await getUserDuos(user.uid);
    if (userDuos.isNotEmpty) {
      throw Exception(
          'Você já está em um duo. Saia do duo atual para criar um novo.');
    }

    final inviteCode = await _generateUniqueInviteCode();
    final now = DateTime.now();

    final duoData = {
      'participants': [user.uid],
      'name': name.trim(),
      'inviteCode': inviteCode,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };

    // Usar transação para garantir consistência
    return await _firestore.runTransaction((transaction) async {
      // Criar o duo no novo path
      final duoId = _firestore.collection(_collection).doc().id;
      final duoMetaRef = _firestore
          .collection(_collection)
          .doc(duoId)
          .collection(inviteCode)
          .doc('__meta');
      transaction.set(duoMetaRef, duoData);

      // Adicionar referência do duo ao usuário
      final userDuoRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection(_userDuosSubcollection)
          .doc(duoId);
      transaction.set(userDuoRef, {
        'duoId': duoId,
        'inviteCode': inviteCode,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });

      return Duo.fromMap(duoData, duoId);
    });
  }

  // Buscar duo pelo código de convite
  Future<Duo?> getDuoByInviteCode(String inviteCode) async {
    // Busca por todos os duos e tenta encontrar o inviteCode
    final duosSnap = await _firestore.collection(_collection).get();
    for (final duoDoc in duosSnap.docs) {
      final metaDoc = await _firestore
          .collection(_collection)
          .doc(duoDoc.id)
          .collection(inviteCode)
          .doc('__meta')
          .get();
      if (metaDoc.exists && metaDoc['inviteCode'] == inviteCode) {
        return Duo.fromFirestore(metaDoc);
      }
    }
    return null;
  }

  // Entrar em um duo
  Future<void> joinDuo({
    required String duoName,
    required String inviteCode,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    // Verificar se o usuário já está em algum duo
    final userDuos = await getUserDuos(user.uid);
    if (userDuos.isNotEmpty) {
      throw Exception(
          'Você já está em um duo. Saia do duo atual para entrar em outro.');
    }

    // Buscar o duo pelo código
    final duo = await getDuoByInviteCode(inviteCode);
    if (duo == null) {
      throw Exception('Duo não encontrado com o código fornecido');
    }

    // Verificar se o nome confere
    if (duo.name.toLowerCase() != duoName.toLowerCase().trim()) {
      throw Exception('Nome do duo não confere');
    }

    // Verificar se o usuário já é membro
    if (duo.isMember(user.uid)) {
      throw Exception('Você já é membro deste duo');
    }

    // Verificar se o duo não está cheio (máximo 2 participantes)
    if (duo.participants.length >= 2) {
      throw Exception('Este duo já atingiu o número máximo de participantes');
    }

    // Usar transação para garantir consistência
    await _firestore.runTransaction((transaction) async {
      final duoMetaRef = _firestore
          .collection(_collection)
          .doc(duo.id)
          .collection(inviteCode)
          .doc('__meta');
      final userDuoRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection(_userDuosSubcollection)
          .doc(duo.id);

      // Atualizar a lista de participantes no duo
      final updatedParticipants = [...duo.participants, user.uid];
      transaction.update(duoMetaRef, {
        'participants': updatedParticipants,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Salvar duoId e inviteCode na referência do usuário
      transaction.set(userDuoRef, {
        'duoId': duo.id,
        'inviteCode': duo.inviteCode,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  // Sair de um duo
  Future<void> leaveDuo(String duoId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final duo = await getDuoById(duoId);
    if (duo == null) {
      throw Exception('Duo não encontrado');
    }

    // Verificar se o usuário é participante
    if (!duo.isParticipant(user.uid)) {
      throw Exception('Você não é membro deste duo');
    }

    // Usar transação para garantir consistência
    await _firestore.runTransaction((transaction) async {
      final duoRef = _firestore.collection(_collection).doc(duoId);
      final userDuoRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection(_userDuosSubcollection)
          .doc(duoId);

      // Remover usuário da lista de participantes
      final updatedParticipants =
          duo.participants.where((id) => id != user.uid).toList();
      transaction.update(duoRef, {
        'participants': updatedParticipants,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Remover referência do duo do usuário
      transaction.delete(userDuoRef);
    });
  }

  // Deletar duo (qualquer participante pode fazer isso)
  Future<void> deleteDuo(String duoId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final duo = await getDuoById(duoId);
    if (duo == null) {
      throw Exception('Duo não encontrado');
    }

    // Verificar se o usuário é participante
    if (!duo.isParticipant(user.uid)) {
      throw Exception('Apenas participantes podem deletar o duo');
    }

    // Usar transação para limpar todas as referências
    await _firestore.runTransaction((transaction) async {
      final duoRef = _firestore.collection(_collection).doc(duoId);

      // Deletar o duo
      transaction.delete(duoRef);

      // Limpar referências de todos os participantes
      for (final participantId in duo.participants) {
        final participantUserDuoRef = _firestore
            .collection('users')
            .doc(participantId)
            .collection(_userDuosSubcollection)
            .doc(duoId);
        transaction.delete(participantUserDuoRef);
      }
    });
  }

  // Obter duo por ID (usando inviteCode salvo na referência do usuário)
  Future<Duo?> getDuoById(String duoId) async {
    // Busca a referência do duo em algum usuário para obter o inviteCode
    final usersSnap = await _firestore.collection('users').get();
    for (final userDoc in usersSnap.docs) {
      final userDuoSnap = await _firestore
          .collection('users')
          .doc(userDoc.id)
          .collection(_userDuosSubcollection)
          .doc(duoId)
          .get();
      if (userDuoSnap.exists &&
          userDuoSnap.data() != null &&
          userDuoSnap.data()!.containsKey('inviteCode')) {
        final inviteCode = userDuoSnap['inviteCode'];
        final metaDoc = await _firestore
            .collection(_collection)
            .doc(duoId)
            .collection(inviteCode)
            .doc('__meta')
            .get();
        if (metaDoc.exists) {
          return Duo.fromFirestore(metaDoc);
        }
      }
    }
    return null;
  }

  // Removido: getUserOwnedDuo

  // Obter todos os duos que o usuário é membro
  Future<List<Duo>> getUserDuos(String userId) async {
    final duos = <Duo>[];
    final userDuosSnap = await _firestore
        .collection('users')
        .doc(userId)
        .collection(_userDuosSubcollection)
        .get();
    for (final doc in userDuosSnap.docs) {
      final duo = await getDuoById(doc.id);
      if (duo != null) {
        duos.add(duo);
      }
    }
    return duos;
  }

  // Remover participante (qualquer participante pode fazer isso)
  Future<void> removeParticipant({
    required String duoId,
    required String participantId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final duo = await getDuoById(duoId);
    if (duo == null) {
      throw Exception('Duo não encontrado');
    }

    // Verificar se o usuário é participante
    if (!duo.isParticipant(user.uid)) {
      throw Exception(
          'Apenas participantes podem remover outros participantes');
    }

    // Verificar se o participante realmente está no duo
    if (!duo.isParticipant(participantId)) {
      throw Exception('Usuário não é participante deste duo');
    }

    // Usar transação para garantir consistência
    await _firestore.runTransaction((transaction) async {
      final duoRef = _firestore.collection(_collection).doc(duoId);
      final participantUserDuoRef = _firestore
          .collection('users')
          .doc(participantId)
          .collection(_userDuosSubcollection)
          .doc(duoId);

      // Remover participante da lista
      final updatedParticipants =
          duo.participants.where((id) => id != participantId).toList();
      transaction.update(duoRef, {
        'participants': updatedParticipants,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Remover referência do participante removido
      transaction.delete(participantUserDuoRef);
    });
  }

  // Stream para escutar mudanças nos duos do usuário
  Stream<List<Duo>> getUserDuosStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_userDuosSubcollection)
        .snapshots()
        .asyncMap((snapshot) async {
      final duos = <Duo>[];
      for (final doc in snapshot.docs) {
        final duo = await getDuoById(doc.id);
        if (duo != null) {
          duos.add(duo);
        }
      }
      return duos;
    });
  }
}
