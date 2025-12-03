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

class ChallengeScore {
  final String duoId;
  final String challengeId;
  final int points;
  final int totalPoints;
  final String? comment;
  final String updatedByUid;
  final DateTime updatedAt;

  const ChallengeScore({
    required this.duoId,
    required this.challengeId,
    required this.points,
    required this.totalPoints,
    required this.updatedByUid,
    required this.updatedAt,
    this.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'duoId': duoId,
      'challengeId': challengeId,
      'points': points,
      'totalPoints': totalPoints,
      'comment': comment,
      'updatedByUid': updatedByUid,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ChallengeScore.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data();
      if (data == null) {
        throw StateError('Score document is empty');
      }
      // Derive ids from path when fields are absent
      final challengeId = doc.id;
      final duoId = data['duoId'];
      final pointsValue = data['points'];
      final totalPointsValue = data['totalPoints'];
      final updatedByUidValue = data['updatedByUid'];
      final updatedAtValue = data['updatedAt'];

      final points = (pointsValue is num) ? pointsValue.toInt() : 0;
      final totalPoints =
          (totalPointsValue is num) ? totalPointsValue.toInt() : points;
      final updatedByUid =
          (updatedByUidValue is String) ? updatedByUidValue : '';
      final updatedAt = (updatedAtValue is Timestamp)
          ? updatedAtValue.toDate()
          : DateTime.now();

      if (duoId == null || duoId.isEmpty) {
        throw StateError(
            'Invalid score document: missing duoId for ${doc.reference.path} id = ${doc.id}');
      }

      return ChallengeScore(
        duoId: duoId,
        challengeId: (data['challengeId'] is String)
            ? data['challengeId'] as String
            : challengeId,
        points: points,
        totalPoints: totalPoints,
        comment: (data['comment'] is String) ? data['comment'] as String : null,
        updatedByUid: updatedByUid,
        updatedAt: updatedAt,
      );
    } catch (e, st) {
      debugPrint(
          '[ChallengeScore.fromFirestore] error on ${doc.reference.path}: $e');
      debugPrint('$st');
      rethrow;
    }
  }
}
