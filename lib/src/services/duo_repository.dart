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
import 'package:flutter/foundation.dart';

class DuoInfo {
  final String duoId;
  final String name;
  final List<String> members;

  const DuoInfo({
    required this.duoId,
    required this.name,
    required this.members,
  });
}

class DuoRepository {
  final FirebaseFirestore _firestore;

  DuoRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<DuoInfo?> getDuoInfo(String duoId) async {
    // Data lives under /duos/{duoId}/invites/{codeId}; collection has a single doc.
    final basePath = 'duos/$duoId';
    final invitesPath = '$basePath/invites';
    try {
      debugPrint('[DuoRepository] fetching $invitesPath');
      final query = await _firestore
          .collection('duos')
          .doc(duoId)
          .collection('invites')
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        debugPrint('[DuoRepository] not found: $invitesPath');
        return null;
      }

      final data = query.docs.first.data();
      final name = (data['name'] as String?) ?? duoId;
      final membersRaw = data['participants'] as List<dynamic>?;
      final members = membersRaw == null
          ? const <String>[]
          : membersRaw
              .map((e) => (e is Map && e['name'] is String)
                  ? e['name'] as String
                  : null)
              .whereType<String>()
              .toList();

      debugPrint(
          '[DuoRepository] fetched duoId=$duoId name=$name members=${members.length}');
      return DuoInfo(duoId: duoId, name: name, members: members);
    } catch (e, st) {
      debugPrint('[DuoRepository] error reading $invitesPath: $e');
      debugPrint('$st');
      rethrow;
    }
  }
}
