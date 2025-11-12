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

enum MediaType { image, video }

class ChallengeSubmission {
  final String id;
  final String challengeId;
  final String duoId;
  final String uploaderUid;
  final String mediaUrl;
  final MediaType mediaType;
  final DateTime submissionTime;
  final String? description;

  const ChallengeSubmission({
    required this.id,
    required this.challengeId,
    required this.duoId,
    required this.uploaderUid,
    required this.mediaUrl,
    required this.mediaType,
    required this.submissionTime,
    this.description,
  });

  factory ChallengeSubmission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeSubmission(
      id: doc.id,
      challengeId: data['challengeId'] ?? '',
      duoId: data['duoId'] ?? '',
      uploaderUid: data['uploaderUid'] ?? '',
      mediaUrl: data['mediaUrl'] ?? '',
      mediaType:
          data['mediaType'] == 'video' ? MediaType.video : MediaType.image,
      submissionTime: (data['submissionTime'] as Timestamp).toDate(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'challengeId': challengeId,
      'duoId': duoId,
      'uploaderUid': uploaderUid,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType == MediaType.video ? 'video' : 'image',
      'submissionTime': Timestamp.fromDate(submissionTime),
      'description': description,
    };
  }
}
