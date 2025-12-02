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

  factory ChallengeScore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Score document is empty');
    }
    return ChallengeScore(
      duoId: data['duoId'] as String,
      challengeId: data['challengeId'] as String,
      points: (data['points'] as num).toInt(),
      totalPoints: (data['totalPoints'] as num).toInt(),
      comment: data['comment'] as String?,
      updatedByUid: data['updatedByUid'] as String,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
