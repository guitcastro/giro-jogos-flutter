import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/duo.dart';

class DuoService {
  static const String _collection = 'duos';
  static const String _userDuosCollection = 'userDuos';

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
    int maxParticipants = 10,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    // Verificar se o usuário já possui um duo como owner
    final existingDuo = await getUserOwnedDuo(user.uid);
    if (existingDuo != null) {
      throw Exception(
          'Você já possui um duo. Exclua o duo atual para criar um novo.');
    }

    final inviteCode = await _generateUniqueInviteCode();
    final now = DateTime.now();

    final duoData = {
      'ownerId': user.uid,
      'participants': <String>[], // Lista vazia inicialmente
      'name': name.trim(),
      'inviteCode': inviteCode,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'maxParticipants': maxParticipants,
    };

    // Usar transação para garantir consistência
    return await _firestore.runTransaction((transaction) async {
      // Criar o duo
      final duoRef = _firestore.collection(_collection).doc();
      transaction.set(duoRef, duoData);

      // Adicionar referência do duo ao usuário
      final userDuoRef =
          _firestore.collection(_userDuosCollection).doc(user.uid);
      transaction.set(userDuoRef, {
        'ownedDuoId': duoRef.id,
        'participatingDuos': <String>[],
        'updatedAt': Timestamp.fromDate(now),
      });

      return Duo.fromMap(duoData, duoRef.id);
    });
  }

  // Buscar duo pelo código de convite
  Future<Duo?> getDuoByInviteCode(String inviteCode) async {
    final query = await _firestore
        .collection(_collection)
        .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    return Duo.fromFirestore(query.docs.first);
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

    // Verificar se o duo não está cheio
    if (duo.isFull) {
      throw Exception('Este duo já atingiu o número máximo de participantes');
    }

    // Usar transação para garantir consistência
    await _firestore.runTransaction((transaction) async {
      final duoRef = _firestore.collection(_collection).doc(duo.id);
      final userDuoRef =
          _firestore.collection(_userDuosCollection).doc(user.uid);

      // Atualizar a lista de participantes no duo
      final updatedParticipants = [...duo.participants, user.uid];
      transaction.update(duoRef, {
        'participants': updatedParticipants,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Atualizar a referência do usuário
      transaction.set(
          userDuoRef,
          {
            'participatingDuos': [duo.id],
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          },
          SetOptions(merge: true));
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

    // Verificar se o usuário é o owner (owner não pode sair, deve deletar o duo)
    if (duo.isOwner(user.uid)) {
      throw Exception(
          'Como dono do duo, você deve deletar o duo ao invés de sair');
    }

    // Verificar se o usuário é participante
    if (!duo.isParticipant(user.uid)) {
      throw Exception('Você não é membro deste duo');
    }

    // Usar transação para garantir consistência
    await _firestore.runTransaction((transaction) async {
      final duoRef = _firestore.collection(_collection).doc(duoId);
      final userDuoRef =
          _firestore.collection(_userDuosCollection).doc(user.uid);

      // Remover usuário da lista de participantes
      final updatedParticipants =
          duo.participants.where((id) => id != user.uid).toList();
      transaction.update(duoRef, {
        'participants': updatedParticipants,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Atualizar referência do usuário
      transaction.update(userDuoRef, {
        'participatingDuos': FieldValue.arrayRemove([duoId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  // Deletar duo (apenas o owner pode fazer isso)
  Future<void> deleteDuo(String duoId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    final duo = await getDuoById(duoId);
    if (duo == null) {
      throw Exception('Duo não encontrado');
    }

    // Verificar se o usuário é o owner
    if (!duo.isOwner(user.uid)) {
      throw Exception('Apenas o dono pode deletar o duo');
    }

    // Usar transação para limpar todas as referências
    await _firestore.runTransaction((transaction) async {
      final duoRef = _firestore.collection(_collection).doc(duoId);

      // Deletar o duo
      transaction.delete(duoRef);

      // Limpar referência do owner
      final ownerUserDuoRef =
          _firestore.collection(_userDuosCollection).doc(user.uid);
      transaction.update(ownerUserDuoRef, {
        'ownedDuoId': FieldValue.delete(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Limpar referências de todos os participantes
      for (final participantId in duo.participants) {
        final participantUserDuoRef =
            _firestore.collection(_userDuosCollection).doc(participantId);
        transaction.update(participantUserDuoRef, {
          'participatingDuos': FieldValue.arrayRemove([duoId]),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    });
  }

  // Obter duo por ID
  Future<Duo?> getDuoById(String duoId) async {
    final doc = await _firestore.collection(_collection).doc(duoId).get();

    if (!doc.exists) {
      return null;
    }

    return Duo.fromFirestore(doc);
  }

  // Obter duo que o usuário possui como owner
  Future<Duo?> getUserOwnedDuo(String userId) async {
    final userDuoDoc =
        await _firestore.collection(_userDuosCollection).doc(userId).get();

    if (!userDuoDoc.exists) {
      return null;
    }

    final data = userDuoDoc.data()!;
    final ownedDuoId = data['ownedDuoId'] as String?;

    if (ownedDuoId == null) {
      return null;
    }

    return await getDuoById(ownedDuoId);
  }

  // Obter todos os duos que o usuário é membro (como owner ou participante)
  Future<List<Duo>> getUserDuos(String userId) async {
    final duos = <Duo>[];

    final userDuoDoc =
        await _firestore.collection(_userDuosCollection).doc(userId).get();

    if (!userDuoDoc.exists) {
      return duos;
    }

    final data = userDuoDoc.data()!;

    // Adicionar duo próprio se existir
    final ownedDuoId = data['ownedDuoId'] as String?;
    if (ownedDuoId != null) {
      final ownedDuo = await getDuoById(ownedDuoId);
      if (ownedDuo != null) {
        duos.add(ownedDuo);
      }
    }

    // Adicionar duos dos quais é participante
    final participatingDuos =
        List<String>.from(data['participatingDuos'] ?? []);
    for (final duoId in participatingDuos) {
      final duo = await getDuoById(duoId);
      if (duo != null) {
        duos.add(duo);
      }
    }

    return duos;
  }

  // Remover participante (apenas o owner pode fazer isso)
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

    // Verificar se o usuário é o owner
    if (!duo.isOwner(user.uid)) {
      throw Exception('Apenas o dono pode remover participantes');
    }

    // Verificar se o participante realmente está no duo
    if (!duo.isParticipant(participantId)) {
      throw Exception('Usuário não é participante deste duo');
    }

    // Usar transação para garantir consistência
    await _firestore.runTransaction((transaction) async {
      final duoRef = _firestore.collection(_collection).doc(duoId);
      final participantUserDuoRef =
          _firestore.collection(_userDuosCollection).doc(participantId);

      // Remover participante da lista
      final updatedParticipants =
          duo.participants.where((id) => id != participantId).toList();
      transaction.update(duoRef, {
        'participants': updatedParticipants,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Atualizar referência do participante removido
      transaction.update(participantUserDuoRef, {
        'participatingDuos': FieldValue.arrayRemove([duoId]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  // Stream para escutar mudanças nos duos do usuário
  Stream<List<Duo>> getUserDuosStream(String userId) {
    return _firestore
        .collection(_userDuosCollection)
        .doc(userId)
        .snapshots()
        .asyncMap((userDuoSnapshot) async {
      if (!userDuoSnapshot.exists) {
        return <Duo>[];
      }

      final data = userDuoSnapshot.data()!;
      final duos = <Duo>[];

      // Adicionar duo próprio se existir
      final ownedDuoId = data['ownedDuoId'] as String?;
      if (ownedDuoId != null) {
        final ownedDuo = await getDuoById(ownedDuoId);
        if (ownedDuo != null) {
          duos.add(ownedDuo);
        }
      }

      // Adicionar duos dos quais é participante
      final participatingDuos =
          List<String>.from(data['participatingDuos'] ?? []);
      for (final duoId in participatingDuos) {
        final duo = await getDuoById(duoId);
        if (duo != null) {
          duos.add(duo);
        }
      }

      return duos;
    });
  }
}
